//
// HistoryStore.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO
import Foundation
import ChatCore
import Additive
import ChatExtensions

internal final class HistoryStore {
    typealias ResponseType = ChatResponse<[Message]>
    private var chat: ChatInternalProtocol
    private var debug = ProcessInfo().environment["talk.pod.ir.chat.debugStore.debug"] == "1"
    private var cache: CacheManager? { chat.cache }
    private var missed: [String: [Message]] = [:]

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func doRequest(_ request: GetHistoryRequest) {
        if chat.config.enableCache {
            requestFromCache(request)
        } else {
            directRequest(request)
        }
    }

    private func requestFromCache(_ request: GetHistoryRequest) {
        if isTimeRequest(request), !isCacheContainsTime(request) {
            directRequest(request)
        } else {
            cache?.message?.fetch(request.fetchRequest) { [weak self] messages, totalCacheCount in
                let messages = messages.map { $0.codable(fillConversation: false) }
                self?.onCacheResponse(request, messages, totalCacheCount)
            }
        }
    }

    private func onCacheResponse(_ req: GetHistoryRequest, _ messages: [Message], _ totalCacheCount: Int) {
        if isComplete(messages, req) {
            emit(makeResponse(req, messages: messages))
        } else if isPartial(messages, req) {
            handlePartialResponse(messages, req)
        } else {
            directRequest(req)
        }
    }

    private func handlePartialResponse(_ messages: [Message], _ req: GetHistoryRequest) {
        if isLastMessage(req) {
            emit(lastMessageResponse(req, messages))
        } else {
            partialRequest(req, messages)
        }
    }

    private func directRequest(_ req: GetHistoryRequest) {
        log("request directly to the chat server")
        chat.prepareToSendAsync(req: req, type: .getHistory)
    }

    private func partialRequest(_ request: GetHistoryRequest, _ messages: [Message]) {
        var req = request
        req.count = max(0, request.count - messages.count)
        requestMissedPart(req, messages)
    }

    private func requestMissedPart(_ req: GetHistoryRequest, _ messages: [Message]) {
        missed[req.uniqueId] = messages
        chat.prepareToSendAsync(req: req, type: .getHistory)
    }

    private func onPartialResponse(_ response: ResponseType, _ part: [Message]) {
        let messageIds = part.compactMap({$0.id})
        var parts = part
        let filtered = response.result?.filter{ !messageIds.contains($0.id ?? -1) } ?? []
        parts.append(contentsOf: filtered)
        let res = makeResponse(response, parts: parts)
        emit(res)
        missed.removeValue(forKey: response.uniqueId ?? "")
    }

    func onHistory(_ response: ResponseType) {
        if let uniqueId = response.uniqueId, let part = missed[uniqueId] {
            onPartialResponse(response, part)
        } else {
            chat.delegate?.chatEvent(event: .message(.history(response)))
        }
        let copies = response.result?.compactMap{$0} ?? []
        if !copies.isEmpty {
            cache?.message?.insert(models: copies, threadId: response.subjectId ?? -1)
        }
    }

    private func emit(_ response: ResponseType) {
        chat.delegate?.chatEvent(event: .message(.history(response)))
    }

    func invalidate() {
        cache?.message?.truncate()
    }

    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "HistoryStore", message: message, persist: false, type: .internalLog, userInfo: [:])
        }
#endif
    }
}

// MARK: Response Builders
fileprivate extension HistoryStore {
    private func makeResponse(_ req: GetHistoryRequest, messages: [Message]) -> ResponseType {
        let resp = ResponseType(uniqueId: req.uniqueId,
                                result: messages,
                                hasNext: messages.count >= req.count,
                                cache: false,
                                subjectId: req.threadId,
                                typeCode: req.toTypeCode(chat))
        return resp
    }

    private func makeResponse(_ response: ResponseType, parts: [Message]) -> ResponseType {
        let res = ResponseType(uniqueId: response.uniqueId,
                               result: parts,
                               error: response.error,
                               contentCount: response.contentCount,
                               hasNext: response.hasNext,
                               cache: false,
                               subjectId: response.subjectId,
                               time: response.time,
                               typeCode: response.typeCode)
        return res
    }

    private func lastMessageResponse(_ req: GetHistoryRequest, _ messages: [Message]) -> ResponseType {
        let resp = ResponseType(uniqueId: req.uniqueId,
                                result: messages,
                                contentCount: 1,
                                hasNext: false,
                                cache: false,
                                subjectId: req.subjectId,
                                typeCode: req.toTypeCode(chat))
        return resp
    }
}

// MARK: Helper functions
fileprivate extension HistoryStore {
    private func isPartial(_ messages: [Message], _ req: GetHistoryRequest) -> Bool {
        !messages.isEmpty && req.count != messages.count
    }

    private func isComplete(_ messages: [Message], _ req: GetHistoryRequest) -> Bool {
        !messages.isEmpty && req.count == messages.count
    }

    private func isCacheContainsTime(_ req: GetHistoryRequest) -> Bool {
        guard let time = req.fromTime ?? req.toTime else { return false }
        return cache?.message?.isContains(time: time, threadId: req.threadId) == true
    }

    private func isTimeRequest(_ req: GetHistoryRequest) -> Bool {
        req.fromTime != nil || req.toTime != nil
    }

    private func isLastMessage(_ req: GetHistoryRequest) -> Bool {
        let conversation = cache?.conversation?.get(id: req.threadId)
        return (req.toTime ?? req.fromTime) == conversation?.lastMessageVO?.time?.uintValue
    }
}
