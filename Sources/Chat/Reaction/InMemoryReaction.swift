//
// InMemoryReaction.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatModels
import ChatCore
import ChatExtensions

/// In Memory reactions.
public final class InMemoryReaction: InMemoryReactionProtocol {
    private let chat: ChatInternalProtocol
    var reactions: ContiguousArray<MessageInMemoryReaction> = []
    private var queue = DispatchQueue(label: "InMemoryReactionSerialQueue")

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func reaction(_ request: UserReactionRequest) -> Bool {
        /// If we have a cached version of messageId in reactions list it means that the last time it was nil and did not have a user reaction.
        if let index = indexOfMessageId(request.messageId) {
            let cachedVersion = reactions[index].currentUserReaction
            let response = ChatResponse<CurrentUserReaction>(uniqueId: request.uniqueId,
                                                             result: .init(messageId: request.messageId, reaction: cachedVersion),
                                                             cache: true,
                                                             subjectId: request.conversationId)
            chat.delegate?.chatEvent(event: .reaction(.reaction(response)))
            let copy = reactions[index].copy
            chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [copy])))
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
        let list = listOfReactionCount(inMemoryMessageIds)
        var copies: [ReactionInMemoryCopy] = []
        if list.count > 0 {
            let response = ChatResponse<[ReactionCountList]>(uniqueId: uniqueId,
                                                             result: list,
                                                             cache: true,
                                                             subjectId: conversationId)
            chat.delegate?.chatEvent(event: .reaction(.count(response)))
            list.forEach { item in
                if let messageId = item.messageId, let index = indexOfMessageId(messageId) {
                    copies.append(reactions[index].copy)
                }
            }
        }
        chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: copies)))
    }

    private func listOfReactionCount(_ messageIds: [Int]) -> [ReactionCountList] {
        messageIds
            .compactMap { messageId in
                ReactionCountList(messageId: messageId, reactionCounts: summary(for: messageId), userReaction: nil)
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

    func getOffset(_ request: RactionListRequest) -> Int? {
        guard let index = indexOfMessageId(request.messageId) else { return nil }
        let reacrionInMemory = reactions[index]
        let allStoredReactions = reacrionInMemory.details
        let byStickerFilter = allStoredReactions.filter({$0.reaction == request.sticker})

        let currentStoredInMemory = request.sticker == nil ? allStoredReactions : byStickerFilter
        let count = currentStoredInMemory.count

        let response = ChatResponse<ReactionList>(uniqueId: request.uniqueId,
                                                  result: .init(messageId: request.messageId, reactions: currentStoredInMemory),
                                                  cache: true,
                                                  subjectId: request.conversationId)
        chat.delegate?.chatEvent(event: .reaction(.list(response)))
        chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [reacrionInMemory.copy])))

        return count
    }

    func onSummaryCount(_ response: ChatResponse<[ReactionCountList]>) {
        var inMemoryReactions: [ReactionInMemoryCopy] = []
        response.result?.compactMap{$0}.forEach { listCount in
            let index = findOrCreateIndex(listCount.messageId ?? 0)
            reactions[index].summary = listCount.reactionCounts ?? []
            setUserReaction(listCount)
            inMemoryReactions.append(reactions[index].copy)
        }
        chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: inMemoryReactions)))
    }

    private func setUserReaction(_ list: ReactionCountList) {
        if let userReaction = list.userReaction, let index = indexOfMessageId(list.messageId ?? 0) {
            reactions[index].currentUserReaction = userReaction
        }
    }

    func onUserReaction(_ response: ChatResponse<CurrentUserReaction>) {
        if let result = response.result, let messageId = result.messageId {
            var copy: ReactionInMemoryCopy
            if let firstIndex = indexOfMessageId(messageId) {
                reactions[firstIndex].currentUserReaction = result.reaction
                copy = reactions[firstIndex].copy
            } else {
                let inMemoryItem = MessageInMemoryReaction(messageId: messageId)
                inMemoryItem.currentUserReaction = result.reaction
                reactions.append(inMemoryItem)
                copy = inMemoryItem.copy
            }
            chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [copy])))
        }
    }

    func onReactionList(_ response: ChatResponse<ReactionList>) {
        let copied = response.result
        if let messageId = copied?.messageId,
           let index = indexOfMessageId(messageId),
           let reactions = copied?.reactions {
            self.reactions[index].appendOrReplaceDetail(reactions: reactions)
            let copy = self.reactions[index].copy
            chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [copy])))
        }
    }

    func onAdd(_ response: ChatResponse<ReactionMessageResponse>) {
        if let messageId = response.result?.messageId {
            let reaction = response.result?.reaction
            let index = findOrCreateIndex(messageId)
            reactions[index].addOrReplaceSummaryCount(sticker: reaction?.reaction ?? Sticker.unknown)
            reactions[index].details.append(.init(id: reaction?.id, reaction: reaction?.reaction, participant: reaction?.participant, time: reaction?.time))
            setUserReaction(index: index, action: response.result)
            chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [reactions[index].copy])))
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
        chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [reactions[index].copy])))
    }

    func onDelete(_ response: ChatResponse<ReactionMessageResponse>) {
        guard let result = response.result, let index = indexOfMessageId(result.messageId) else { return }
        reactions[index].deleteSummaryCount(sticker: result.reaction?.reaction ?? Sticker.unknown)
        reactions[index].details.removeAll(where: {$0.participant?.id == result.reaction?.participant?.id})
        removeCurrentUserReaction(index: index, action: result)
        chat.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messages: [reactions[index].copy])))
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

    public func currentReaction(_ messageId: Int) -> Reaction? {
        queue.sync {
            guard let index = indexOfMessageId(messageId) else { return nil }
            return reactions[index].currentUserReaction
        }
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

    /// Clear in memory cache upon disconnect.
    public func invalidate() {
        queue.sync {
            reactions.removeAll()
        }
    }
}
