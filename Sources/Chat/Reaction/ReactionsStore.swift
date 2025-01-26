//
// ReactionsStore.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatModels
import ChatCore
import ChatExtensions

@ChatGlobalActor
public final class ReactionsStore {
    private let chat: ChatInternalProtocol
    var reactions: ContiguousArray<MessageInMemoryReaction> = []
    private var queue = DispatchQueue(label: "ReactionsStoreQueue")
    var listRequests: [String: ReactionListRequest] = [:]
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func reaction(_ request: UserReactionRequest) -> Bool {
        /// If we have a cached version of messageId in reactions list it means that the last time it was nil and did not have a user reaction.
        if let response = userReactionResponse(request: request) {
            emit(.reaction(response))
            return true
        }
        return false
    }
    
    func storeNewCountRequestMessageIds(_ messageIds: [Int]) {
        queue.sync {
            messageIds.forEach { messageId in
                reactions.append(.init(messageId: messageId))
            }
        }
    }
    
    func countEvent(inMemoryMessageIds: [Int], uniqueId: String, conversationId: Int) {
        if let response = countCacheResponse(inMemoryMessageIds, uniqueId, conversationId) {
            emit(.count(response))
        }
    }
    
    private func listOfReactionCount(_ messageIds: [Int]) -> [ReactionCountList] {
        messageIds
            .compactMap { messageId in
                let userReaction: Reaction? = reactions.first(where: {$0.messageId == messageId})?.currentUserReaction
                return ReactionCountList(messageId: messageId, reactionCounts: summary(for: messageId), userReaction: userReaction)
            }
    }
    
    /// Generate list of messageIds where they are available in memory.
    private func inMemoryMessageIds(_ messageIds: [Int]) -> [Int] {
        let cachedMessageIds = reactions.map{$0.messageId}
        return messageIds
            .filter { requestMessageId in
                cachedMessageIds.contains(where: {$0 == requestMessageId} )
            }
    }
    
    /// Generate list of messageIds where they are not available in memory.
    private func notInMemoryMessageIds(_ messageIds: [Int]) -> [Int] {
        let cachedMessageIds = reactions.map{$0.messageId}
        return messageIds
            .filter { requestMessageId in
                !cachedMessageIds.contains(where: {$0 == requestMessageId})
            }
    }
    
    func tupleOfMessageIds(_ messageIds: [Int]) -> (inMemory: [Int], notInMemory:[Int]) {
        let inMemoryMessageIds = inMemoryMessageIds(messageIds)
        let notInMemoryMessageIds = notInMemoryMessageIds(messageIds)
        return (inMemory: inMemoryMessageIds, notInMemory: notInMemoryMessageIds)
    }
    
    func getStickerOffset(_ request: ReactionListRequest) -> ChatResponse<ReactionList>? {
        guard let index = indexOfMessageId(request.messageId) else { return nil }
        let reactionInMemory = reactions[index]        
        return normalReactionTabWithStickerCacheResponse(request, reactionInMemory)
    }
    
    func getAllDetailOffset(_ request: ReactionListRequest) -> ChatResponse<ReactionList>? {
        guard let index = indexOfMessageId(request.messageId) else { return nil }
        let reactionInMemory = reactions[index]
        return noStickerTabCacheReactions(request, reactionInMemory)
    }
    
    func onSummaryCount(_ response: ChatResponse<[ReactionCountList]>) {
        response.result?.compactMap{$0}.forEach { listCount in
            let index = findOrCreateIndex(listCount.messageId ?? 0)
            reactions[index].summary = listCount.reactionCounts ?? []
            setUserReaction(listCount)
        }
    }
    
    private func setUserReaction(_ list: ReactionCountList) {
        if let userReaction = list.userReaction, let index = indexOfMessageId(list.messageId ?? 0) {
            reactions[index].currentUserReaction = userReaction
        }
    }
    
    func onUserReaction(_ response: ChatResponse<CurrentUserReaction>) {
        if let result = response.result, let messageId = result.messageId {
            if let firstIndex = indexOfMessageId(messageId) {
                reactions[firstIndex].currentUserReaction = result.reaction
            } else {
                let inMemoryItem = MessageInMemoryReaction(messageId: messageId)
                inMemoryItem.currentUserReaction = result.reaction
                reactions.append(inMemoryItem)
            }
        }
    }
    
    func onReactionList(_ response: ChatResponse<ReactionList>) {
        guard let uniqueId = response.uniqueId, let listRequest = listRequests[uniqueId] else { return }
        let copied = response.result
        if let messageId = copied?.messageId,
           let index = indexOfMessageId(messageId),
           let reactions = copied?.reactions {
               self.reactions[index].appendOrReplaceDetail(reactions: reactions, listRequest: listRequest)
        }
        listRequests.removeValue(forKey: uniqueId)
    }
    
    func onAdd(_ response: ChatResponse<ReactionMessageResponse>) {
        if let messageId = response.result?.messageId, isInCache(messageId){
            let reaction = response.result?.reaction
            let index = findOrCreateIndex(messageId)
            reactions[index].addOrReplaceSummaryCount(sticker: reaction?.reaction ?? Sticker.unknown)
            reactions[index].details.append(.init(id: reaction?.id, reaction: reaction?.reaction, participant: reaction?.participant, time: reaction?.time))
            setUserReaction(index: index, action: response.result)
        }
    }
    
    private func isInCache(_ messageId: Int) -> Bool {
        reactions.contains(where: {$0.messageId == messageId})
    }
    
    func onReplace(_ response: ChatResponse<ReactionMessageResponse>) {
        guard let messageId = response.result?.messageId,
              let result = response.result,
              let index = indexOfMessageId(messageId)
        else { return }
        reactions[index].deleteSummaryCount(sticker: result.oldSticker ?? Sticker.unknown)
        removeCurrentUserReaction(index: index, action: result)
        reactions[index].addOrReplaceSummaryCount(sticker: response.result?.reaction?.reaction ?? Sticker.unknown)
        setUserReaction(index: index, action: result)
    }
    
    func onDelete(_ response: ChatResponse<ReactionMessageResponse>) {
        guard let result = response.result, let index = indexOfMessageId(result.messageId) else { return }
        reactions[index].deleteSummaryCount(sticker: result.reaction?.reaction ?? Sticker.unknown)
        reactions[index].details.removeAll(where: {$0.participant?.id == result.reaction?.participant?.id})
        removeCurrentUserReaction(index: index, action: result)
    }
    
    private func removeCurrentUserReaction(index: Int, action: ReactionMessageResponse) {
        if chat.userInfo?.id == action.reaction?.participant?.id {
            reactions[index].currentUserReaction = nil
        }
    }
    
    private func setUserReaction(index: Int, action: ReactionMessageResponse?) {
        if chat.userInfo?.id == action?.reaction?.participant?.id, let reaction = action?.reaction {
            reactions[index].currentUserReaction = reaction
        }
    }
    
    private func findOrCreateIndex(_ messageId: Int) -> Int {
        if let index = indexOfMessageId(messageId) {
            return index
        } else {
            reactions.append(.init(messageId: messageId))
            return max(0, reactions.count - 1)
        }
    }
    
    private func indexOfMessageId(_ messageId: Int?) -> Int? {
        reactions.firstIndex(where: { $0.messageId == messageId })
    }
    
    public func summary(for messageId: Int) -> [ChatModels.ReactionCount] {
        queue.sync {
            guard let index = indexOfMessageId(messageId) else { return [] }
            return reactions[index].summary
        }
    }
    
    internal func createEmptySlot(messageId: Int) {
        reactions.append(.init(messageId: messageId))
    }
    
    internal func onNewMessage(messageId: Int) {
        let inMemoryItem = MessageInMemoryReaction(messageId: messageId)
        reactions.append(inMemoryItem)
    }
    
    /// Clear in memory cache upon disconnect.
    public func invalidate() {
        queue.sync {
            listRequests.removeAll()
            reactions.removeAll()
        }
    }
    
    private func emit(_ event: ReactionEventTypes) {
        chat.delegate?.chatEvent(event: .reaction(event))
    }
}

fileprivate extension ReactionsStore {
    
     func userReactionResponse(request: UserReactionRequest) -> ChatResponse<CurrentUserReaction>? {
        guard let index = indexOfMessageId(request.messageId) else { return nil }
        let cachedVersion = reactions[index].currentUserReaction
        let typeCode = request.toTypeCode(chat)
        let response = ChatResponse<CurrentUserReaction>(uniqueId: request.uniqueId,
                                                         result: .init(messageId: request.messageId, reaction: cachedVersion),
                                                         cache: true,
                                                         subjectId: request.conversationId,
                                                         typeCode: typeCode)
        return response
    }
    
    func countCacheResponse(_ inMemoryMessageIds: [Int], _ uniqueId: String, _ conversationId: Int) ->ChatResponse<[ReactionCountList]>? {
        let list = listOfReactionCount(inMemoryMessageIds)
        guard !list.isEmpty else { return nil }
        let response = ChatResponse<[ReactionCountList]>(uniqueId: uniqueId,
                                                         result: list,
                                                         cache: true,
                                                         subjectId: conversationId,
                                                         typeCode: nil)
        return response
    }
    
    func normalReactionTabWithStickerCacheResponse(_ request: ReactionListRequest,
                                     _ inMemoryReaction: MessageInMemoryReaction) -> ChatResponse<ReactionList>? {
        let allStoredReactions = inMemoryReaction.details
        let byStickerFilter = allStoredReactions.filter({$0.reaction == request.sticker})
        
        let currentStoredInMemory = request.sticker == nil ? allStoredReactions : byStickerFilter
        let count = currentStoredInMemory.count
        
        let typeCode = request.toTypeCode(chat)
        let response = ChatResponse<ReactionList>(uniqueId: request.uniqueId,
                                                  result: .init(messageId: request.messageId, reactions: currentStoredInMemory),
                                                  cache: true,
                                                  subjectId: request.conversationId, typeCode: typeCode)
        return response
    }
    
    func noStickerTabCacheReactions(_ request: ReactionListRequest, _ inMemoryReaction: MessageInMemoryReaction) -> ChatResponse<ReactionList>? {
        if let reactions = inMemoryReaction.containsAllOffset(request) {
            /// Response with cache
            let typeCode = request.toTypeCode(chat)
            let response = ChatResponse<ReactionList>(uniqueId: request.uniqueId,
                                                      result: .init(messageId: request.messageId, reactions: reactions),
                                                      cache: true,
                                                      subjectId: request.conversationId, typeCode: typeCode)
            return response
        }
        return nil
    }
}
