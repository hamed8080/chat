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

final class HistoryStore {
    var history: [Conversation.ID: ContiguousArray<Message>] = [:]
    var chat: ChatInternalProtocol
    private var debug = ProcessInfo().environment["talk.pod.ir.chat.debugStore.debug"] == "1"

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func doRequest(_ request: GetHistoryRequest) {
        if let resp = respondWithFromTime(request) {
            log("responded with from time cache")
            emit(resp)
            return
        } else if let resp = respondWithToTime(request) {
            emit(resp)
            log("responded with to time cache")
            return
        } else if let resp = respondWithOffset(request) {
            emit(resp)
            log("responded with offset cache")
            return
        } else {
            // Directly request to the server
            log("responded with direct request to the server")
            chat.prepareToSendAsync(req: request, type: .getHistory)
        }
    }

    func respondWithFromTime(_ request: GetHistoryRequest) -> ChatResponse<[Message]>? {
        guard let storeResult: [Message] = messagesWithFromTime(request) else { return nil }
        return makeResponse(request, messages: storeResult)
    }

    func respondWithToTime(_ request: GetHistoryRequest) -> ChatResponse<[Message]>? {
        guard let storeResult = messagesWithToTime(request) else { return nil }
        if storeResult.isEmpty { return nil }
        return makeResponse(request, messages: storeResult)
    }

    func respondWithOffset(_ request: GetHistoryRequest) -> ChatResponse<[Message]>? {
        guard let storeResult: [Message] = messagesWithOffset(request) else { return nil }
        if storeResult.isEmpty { return nil }
        return makeResponse(request, messages: storeResult)
    }

    func messagesWithFromTime(_ req: GetHistoryRequest) -> [Message]? {
        guard let fromTime = req.fromTime else { return nil }
        let messages = history[req.threadId]?
            .filter{$0.time ?? 0 > fromTime}
            .prefix(req.count)
        return Array(messages ?? [])
    }

    func messagesWithToTime(_ req: GetHistoryRequest) -> [Message]? {
        guard let toTime = req.toTime else { return nil }
        let messages = history[req.threadId]?
            .filter{$0.time ?? 0 < toTime }
            .suffix(req.count)
        return Array(messages ?? [])
    }

    func messagesWithOffset(_ req: GetHistoryRequest) -> [Message]? {
        if !hasOffset(req) { return nil }
        guard let messages = history[req.threadId] else { return nil }
        if req.offset < messages.count, req.count <= messages.count {
            let end = req.offset + req.count
            let slicedArray = messages[req.offset..<end]
            return Array(slicedArray)
        }
        return nil
    }

    func hasOffset(_ req: GetHistoryRequest) -> Bool {
        guard req.offset >= 0, let array = history[req.threadId] else { return false }
        if req.offset < array.count {
            return true
        }
        return false
    }

    func onHistory(_ response: ChatResponse<[Message]>) {
        guard let threadId = response.subjectId else { return }
        if history[threadId] == nil {
            history[threadId] = []
        }
        response.result?.forEach({ message in
            if history[threadId]?.contains(where: {$0.id == message.id}) == false {
                history[threadId]?.append(message)
            }
        })
        sort(threadId)
        emit(response)
    }

    func sort(_ threadId: Int) {
        history[threadId]?.sort(by: {$0.time ?? 0 < $1.time ?? 0})
    }

    func makeResponse(_ req: GetHistoryRequest, messages: [Message]) -> ChatResponse<[Message]> {
        let resp = ChatResponse<[Message]>(uniqueId: req.uniqueId,
                                           result: messages,
                                           hasNext: req.count == messages.count,
                                           subjectId: req.threadId,
                                           typeCode: req.toTypeCode(chat))
        return resp
    }

    func emit(_ response: ChatResponse<[Message]>) {
        chat.delegate?.chatEvent(event: .message(.history(response)))
    }

    func invalidate() {
        history = [:]
    }

    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "HistoryStore", message: message, persist: false, type: .internalLog, userInfo: [:])
        }
#endif
    }
}
