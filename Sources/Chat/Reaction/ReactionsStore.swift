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
    private var reactions: ContiguousArray<MessageInMemoryReaction> = []
    private var queue = DispatchQueue(label: "ReactionsStoreQueue")
    var listRequests: [String: ReactionListRequest] = [:]
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func reaction(_ request: UserReactionRequest) -> ChatResponse<CurrentUserReaction>? {
        guard let index = indexOfMessageId(request.messageId),
              let cachedVersion = reactions[index].currentUserReaction else { return nil }
        return request.toCurrentUserReactionResponse(reaction: cachedVersion, typeCode: request.toTypeCode(chat))
    }
    
    func storeNewCountRequestMessageIds(_ messageIds: [Int]) {
        queue.sync {
            messageIds.forEach { messageId in
                reactions.append(.init(messageId: messageId))
            }
        }
    }
    
    func count(inMemoryMessageIds: [Int], request: ReactionCountRequest) -> ChatResponse<[ReactionCountList]>? {
        let list = listOfReactionCount(inMemoryMessageIds)
        guard !list.isEmpty else { return nil }
        return request.toCountListResponse(list: list, typeCode: request.toTypeCode(chat))
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
            reactions[index].currentUserReaction = listCount.userReaction
        }
    }
    
    func onUserReaction(_ response: ChatResponse<CurrentUserReaction>) {
        guard let result = response.result, let messageId = result.messageId else { return }
        if let firstIndex = indexOfMessageId(messageId) {
            reactions[firstIndex].currentUserReaction = result.reaction
        } else {
            reactions.append(MessageInMemoryReaction(messageId: messageId, currentUserReaction: result.reaction))
        }
    }
    
    func onReactionList(_ response: ChatResponse<ReactionList>) {
        guard let uniqueId = response.uniqueId,
              let listRequest = listRequests[uniqueId],
              let copied = response.result,
              let messageId = copied.messageId,
              let index = indexOfMessageId(messageId),
              let reactions = copied.reactions
        else {
            /// Clean up the request if reactions is nil
            listRequests.removeValue(forKey: response.uniqueId ?? "")
            return
        }
        self.reactions[index].appendOrReplaceDetail(reactions: reactions, listRequest: listRequest)
        listRequests.removeValue(forKey: uniqueId)
    }
    
    func onAdd(_ response: ChatResponse<ReactionMessageResponse>) {
        if let messageId = response.result?.messageId, let index = indexOfMessageId(messageId) {
            let reaction = response.result?.reaction
            reactions[index].addOrReplaceSummaryCount(sticker: reaction?.reaction ?? Sticker.unknown)
            reactions[index].details.append(.init(id: reaction?.id, reaction: reaction?.reaction, participant: reaction?.participant, time: reaction?.time))
            setUserReaction(index: index, action: response.result)
        }
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
            reactions.append(MessageInMemoryReaction(messageId: messageId))
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
}

fileprivate extension ReactionsStore {
    func normalReactionTabWithStickerCacheResponse(_ request: ReactionListRequest, _ memReaction: MessageInMemoryReaction) -> ChatResponse<ReactionList>? {
        let allStoredReactions = memReaction.details
        let byStickerFilter = allStoredReactions.filter({$0.reaction == request.sticker})
        let endIndex = request.offset + request.count
        if !byStickerFilter.indices.contains(where: { endIndex == $0 }) { return nil }
        let slice = byStickerFilter[request.offset...endIndex]
        let typeCode = request.toTypeCode(chat)
        return request.toListResponse(reactions: Array(slice), typeCode: typeCode)
    }
    
    func noStickerTabCacheReactions(_ request: ReactionListRequest, _ inMemoryReaction: MessageInMemoryReaction) -> ChatResponse<ReactionList>? {
        if let reactions = inMemoryReaction.containsAllOffset(request) {
            _ = request.toListResponse(reactions: reactions, typeCode: request.toTypeCode(chat))
        }
        return nil
    }
}
