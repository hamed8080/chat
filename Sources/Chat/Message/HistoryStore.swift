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

    internal func doRequest(_ request: GetHistoryRequest) async {
        if chat.config.enableCache {
            await requestFromCache(request)
        } else {
            directRequest(request)
        }
    }

    private func requestFromCache(_ request: GetHistoryRequest) async {
        let canFetchFromCache = request.canFetchFromCache
        if !canFetchFromCache {
            requestToIgnoreCache[request.uniqueId] = request
            directRequest(request)
        } else if isTimeRequest(request) {
            await requestFromCacheWithTime(request)
        } else if isOffsetRequest(request) {
            await requestFromCacheWithOffset(request)
        } else {
            directRequest(request)
        }
    }

    
    @MainActor
    private func requestFromCacheWithTime(_ req: GetHistoryRequest) async {
        if await !isCacheContainsTime(req) {
            await directRequest(req)
            return
        }
        let messageCache = await cache?.message
        if let (messages, totalCacheCount) = messageCache?.fetch(req.fetchRequest) {
            let messages = messages.map { $0.codable(fillConversation: false) }
            await onCacheResponse(req, messages, totalCacheCount)
        }
    }

    private func requestFromCacheWithOffset(_ req: GetHistoryRequest) async {
        if await !hasLastMessageOfTheThread(threadId: req.threadId.nsValue) {
            directRequest(req)
        } else {
            let (isChain, chunk) = await chainedMessages(req: req)
            if !isChain {
                directRequest(req)
            } else {
                emit(makeResponse(req, messages: chunk))
            }
        }
    }

    private func onCacheResponse(_ req: GetHistoryRequest, _ messages: [Message], _ totalCacheCount: Int) async {
        if isComplete(messages, req), checkChainFromBottomToTop(messages: messages) {
            emit(makeResponse(req, messages: messages))
        } else if isPartial(messages, req) {
            await handlePartialResponse(messages, req)
        } else {
            directRequest(req)
        }
    }

    private func handlePartialResponse(_ messages: [Message], _ req: GetHistoryRequest) async {
        if await isLastMessageTime(req) {
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

    internal func onHistory(_ response: ResponseType) async {
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
                if await isLoadMoreOrLaodBottom(sorted: sorted) {
                    cache?.message?.insert(models: sorted, threadId: response.subjectId ?? -1)
                } else if await hasLastMessageOnOpenning(sorted: sorted) {
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

    @MainActor
    private func isCacheContainsTime(_ req: GetHistoryRequest) async -> Bool {
        guard let time = req.fromTime ?? req.toTime else { return false }
        let messageCache = await cache?.message
        return messageCache?.isContains(time: time, threadId: req.threadId) == true
    }

    private func isTimeRequest(_ req: GetHistoryRequest) -> Bool {
        req.fromTime != nil || req.toTime != nil
    }

    private func isLastMessageTime(_ req: GetHistoryRequest) async -> Bool {
        let lstMsg = await lastMessageIn(threadId: req.threadId.nsValue)
        return (req.toTime ?? req.fromTime) == lstMsg?.time
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

    private func hasLastMessageOfTheThread(threadId: NSNumber) async -> Bool {
        guard
            let lstId = await lastMessageIn(threadId: threadId)?.id,
            await messageExist(lstId as NSNumber) == true
        else { return false }
        return true
    }

    private func lastMessageIn(threadId: NSNumber) async -> Message? {
        await conversationWith(threadId)?.lastMessageVO?.toMessage
    }

    @MainActor
    private func conversationWith(_ id: NSNumber) async -> Conversation? {
        let conversationCache = await cache?.conversation
        return conversationCache?.get(id: id)?.codable()
    }

    @MainActor
    private func messageExist(_ id: NSNumber) async -> Bool {
        let messageCache = await cache?.message
        return messageCache?.get( id: id) != nil
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
    
    @MainActor
    private func chainedMessages(req: GetHistoryRequest) async -> (Bool, [Message]) {
        let startIndex = req.offset
        let endIndex = (req.offset + req.count) - 1
        let req = FetchMessagesRequest(threadId: req.threadId, count: endIndex + 1)
        let messageCache = await cache?.message
        if let (messages, _) = messageCache?.fetch(req) {
            let reversed = Array(messages.reversed()).compactMap{$0.codable(fillConversation: false)}
            return await chunk(reversed, startIndex, endIndex)
        }
        return (false, [])
    }
    
    @ChatGlobalActor
    private func chunk(_ reversed: [CDMessage.Model], _ startIndex: Int, _ endIndex: Int) async -> (Bool, [Message]) {
        if !self.checkChain(messages: reversed) || !self.offsetsAreExist(reversed, startIndex, endIndex) {
            return (false, [])
        }
        let chunk = Array(reversed[startIndex...endIndex])
        return (true, chunk)
    }
    
    private func hasLastMessageOnOpenning(sorted: [Message]) async -> Bool {
        let threadId = sorted.last?.conversation?.id ?? sorted.last?.threadId
        let lastMessage = await lastMessageIn(threadId: threadId?.nsValue ?? -1)
        if let _ = threadId, let lastMessageId = lastMessage?.id {
            return sorted.contains(where: { $0.id == lastMessageId })
        }
        return false
    }
    
    private func isLoadMoreOrLaodBottom(sorted: [Message]) async -> Bool {
        let chainTop = await isResponseTopChainBottomCurrent(sorted)
        let chainBottom = await isResponseBottomChainTopCurrent(sorted)
        return chainBottom || chainTop
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
    
    @MainActor
    private func isResponseBottomChainTopCurrent(_ sorted: [Message]) async -> Bool {
        guard
            let bottomId = sorted.last?.id,
            let threadId = sorted.last?.conversation?.id ?? sorted.last?.threadId
        else { return false }
        let messageCache = await cache?.message
        let next = messageCache?.next(threadId: threadId, messageId: bottomId)?.codable()
        return next?.previousId == bottomId
    }
    
    @MainActor
    private func isResponseTopChainBottomCurrent(_ sorted: [Message]) async -> Bool {
        guard
            let prevId = sorted.first?.previousId,
            let threadId = sorted.first?.conversation?.id ?? sorted.first?.threadId
        else { return false }
        let messageCache = await cache?.message
        return messageCache?.isContains(messageId: prevId, threadId: threadId) == true
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
