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

@ChatGlobalActor
internal final class HistoryStore {
    typealias ResponseType = ChatResponse<[Message]>
    private var chat: ChatInternalProtocol
    private var debug = ProcessInfo().environment["ENABLE_HISTORY_STORE_LOGGING"] == "1"
    private var cache: CacheManager? { chat.cache }
    private var missed: [String: [Message]] = [:]
    /// These requests don't have a contigous response,
    /// so they should not be stored in the CoreData.
    private var requestToIgnoreCache: [String: GetHistoryRequest] = [:]

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    internal func doRequest(_ request: GetHistoryRequest) {
        if chat.config.enableCache {
            requestFromCache(request)
        } else {
            directRequest(request)
        }
    }

    private func requestFromCache(_ request: GetHistoryRequest) {
        let canFetchFromCache = request.canFetchFromCache
        if !canFetchFromCache {
            requestToIgnoreCache[request.uniqueId] = request
            directRequest(request)
        } else if isTimeRequest(request) {
            requestFromCacheWithTime(request)
        } else if isOffsetRequest(request) {
            requestFromCacheWithOffset(request)
        } else {
            directRequest(request)
        }
    }

    private func requestFromCacheWithTime(_ req: GetHistoryRequest) {
        if !isCacheContainsTime(req) {
            directRequest(req)
            return
        }
        cache?.message?.fetch(req.fetchRequest) { [weak self] messages, totalCacheCount in
            let messages = messages.map { $0.codable(fillConversation: false) }
            Task { @ChatGlobalActor [weak self] in
                self?.onCacheResponse(req, messages, totalCacheCount)
            }
        }
    }

    private func requestFromCacheWithOffset(_ req: GetHistoryRequest) {
        if !hasLastMessageOfTheThread(threadId: req.threadId.nsValue) {
            directRequest(req)
        } else {
            chainedMessages(req: req) { isChain, chunk in
                Task { @ChatGlobalActor [weak self] in
                    if !isChain {
                        self?.directRequest(req)
                    } else if let self = self {
                        emit(makeResponse(req, messages: chunk))
                    }
                }
            }
        }
    }

    private func onCacheResponse(_ req: GetHistoryRequest, _ messages: [Message], _ totalCacheCount: Int) {
        if isComplete(messages, req), checkChainFromBottomToTop(messages: messages) {
            emit(makeResponse(req, messages: messages))
        } else if isPartial(messages, req) {
            handlePartialResponse(messages, req)
        } else {
            directRequest(req)
        }
    }

    private func handlePartialResponse(_ messages: [Message], _ req: GetHistoryRequest) {
        if isLastMessageTime(req) {
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

    internal func onHistory(_ response: ResponseType) {
        if let uniqueId = response.uniqueId, let part = missed[uniqueId] {
            onPartialResponse(response, part)
        } else {
            let copy = response
            chat.delegate?.chatEvent(event: .message(.history(copy)))
        }
        let copies = response.result?.compactMap{$0} ?? []
        let sorted = sortAscending(messages: copies)
        if !copies.isEmpty {
            if let key = requestToIgnoreCache.first(where: {$0.key == response.uniqueId })?.key {
                requestToIgnoreCache.removeValue(forKey: key)
            } else {
                let isChain = allResponseChain(sorted)
                if !isChain { return }
                if isLoadMoreOrLaodBottom(sorted: sorted) {
                    cache?.message?.insert(models: sorted, threadId: response.subjectId ?? -1)
                } else if hasLastMessageOnOpenning(sorted: sorted) {
                    cache?.message?.insert(models: sorted, threadId: response.subjectId ?? -1)
                }
            }
        }
    }

    private func emit(_ response: ResponseType) {
        chat.delegate?.chatEvent(event: .message(.history(response)))
    }

    func invalidate() {
        cache?.message?.truncate()
        missed.removeAll()
        requestToIgnoreCache.removeAll()
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

    private func isLastMessageTime(_ req: GetHistoryRequest) -> Bool {
        let lstMsg = lastMessageIn(threadId: req.threadId.nsValue)
        return (req.toTime ?? req.fromTime) == lstMsg?.time?.uintValue
    }

    private func isOffsetRequest(_ req: GetHistoryRequest) -> Bool {
        req.offset >= 0
    }

    private func hasMoreTopWithOffset(result: [Message]) -> Bool {
        result.first?.previousId != nil
    }

    private func hasMoreBottomWithOffset(result: [Message], threadLastMessageId: Int) -> Bool {
        result.last?.id != threadLastMessageId
    }

    private func hasLastMessageOfTheThread(threadId: NSNumber) -> Bool {
        guard
            let lstId = lastMessageIn(threadId: threadId)?.id,
            let _ = messageWith(lstId)
        else { return false }
        return true
    }

    private func lastMessageIn(threadId: NSNumber) -> CDMessage? {
        conversationWith(threadId)?.lastMessageVO
    }

    private func conversationWith(_ id: NSNumber) -> CDConversation? {
        cache?.conversation?.get(id: id)
    }

    private func messageWith(_ id: NSNumber) -> CDMessage? {
        cache?.message?.get(id: id)
    }

    private func offsetsAreExist(_ messages: [Message], _ startIndex: Int, _ endIndex: Int) -> Bool {
        let hasStartIndex = messages.indices.contains(where: { $0 == startIndex })
        let hasEndIndex = messages.indices.contains(where: { $0 == endIndex })
        return hasStartIndex && hasEndIndex
    }

    private func checkChain(messages: [Message]) -> Bool {
        for message in messages {
            if let prevId = message.previousId, !messages.contains(where: {$0.id == prevId}), message.id != messages.last?.id {
                return false
            }
        }
        return true
    }

    private func checkChainFromBottomToTop(messages: [Message]) -> Bool {
        for message in messages.dropFirst().sorted(by: {$0.time ?? 0 < $1.time ?? 0 }) {
            if let prevId = message.previousId, !messages.contains(where: {$0.id == prevId}) {
                return false
            }
        }
        return true
    }

    private func chainedMessages(req: GetHistoryRequest, completion: @escaping @Sendable (Bool, [Message]) -> Void) {
        let startIndex = req.offset
        let endIndex = (req.offset + req.count) - 1
        let req = FetchMessagesRequest(threadId: req.threadId, count: endIndex + 1)
        cache?.message?.fetch(req) { [weak self] messages, totalCount in
            let reversed = Array(messages.reversed()).compactMap{$0.codable(fillConversation: false)}
            Task { @ChatGlobalActor [weak self] in
                guard let self = self else { return }
                if !self.checkChain(messages: reversed) || !self.offsetsAreExist(reversed, startIndex, endIndex) {
                    completion(false, [])
                    return
                }
                let chunk = Array(reversed[startIndex...endIndex])
                completion(true, chunk)
            }
        }
    }
    
    private func hasLastMessageOnOpenning(sorted: [Message]) -> Bool {
        let threadId = sorted.last?.conversation?.id ?? sorted.last?.threadId
        let lastMessage = lastMessageIn(threadId: threadId?.nsValue ?? -1)
        if let threadId = threadId, let lastMessageId = lastMessage?.id?.intValue {
            return sorted.contains(where: { $0.id == lastMessageId })
        }
        return false
    }
    
    private func isLoadMoreOrLaodBottom(sorted: [Message]) -> Bool {
        let result = isResponseBottomChainTopCurrent(sorted) || isResponseTopChainBottomCurrent(sorted)
        return result
    }
    
    /// Older to newer values
    /// Older values are at top, and newer values are at bottom.
    private func sortAscending(messages: [Message]) -> [Message] {
        messages.sorted(by: { $0.id ?? -0 < $1.id ?? 0 })
    }
    
    private func allResponseChain(_ sorted: [Message]) -> Bool {
        let reversed = sorted.reversed()
        for message in reversed {
            if let prevId = message.previousId,
               !sorted.contains(where: {$0.id == prevId}),
               message.id != reversed.last?.id {
                return false
            }
        }
        return true
    }
    
    private func isResponseBottomChainTopCurrent(_ sorted: [Message]) -> Bool {
        guard
            let bottomId = sorted.last?.id,
            let threadId = sorted.last?.conversation?.id ?? sorted.last?.threadId
        else { return false }
        let next = cache?.message?.next(threadId: threadId, messageId: bottomId)
        return next?.previousId?.intValue == bottomId
    }
    
    private func isResponseTopChainBottomCurrent(_ sorted: [Message]) -> Bool {
        guard
            let prevId = sorted.first?.previousId,
            let threadId = sorted.first?.conversation?.id ?? sorted.first?.threadId
        else { return false }
        return cache?.message?.isContains(messageId: prevId, threadId: threadId) == true
    }
}

fileprivate extension Int {
    var nsValue: NSNumber { NSNumber(integerLiteral: self) }
}

fileprivate extension GetHistoryRequest {
    var canFetchFromCache: Bool {
        unreadMentioned == nil && query == nil && hashtag == nil && newMessages == nil && messageType == nil
    }
}
