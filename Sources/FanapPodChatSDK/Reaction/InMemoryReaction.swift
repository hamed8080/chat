//
// InMemoryReaction.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public protocol InMemoryReactionProtocol {
    /// Return current user reaction for a message if there is any.
    func currentReaction(_ messageId: Int) -> Reaction?

    /// Return list of stickers and count per messageId.
    func summary(for messageId: Int) -> [ReactionCount]
}

/// In Memory reactions.
public final class InMemoryReaction: InMemoryReactionProtocol {
    public weak var chat: Chat?
    var reactions: [MessageInMemoryReaction] = []

    init() {}

    func reaction(_ request: UserReactionRequest) -> Bool {
        /// If we have a cached version of messgeId in reactions list it means that the last time it was nil and did not have a user reaction.
        if let index = indexOfMessageId(request.messageId) {
            let cachedVersion = reactions[index].currentUserReaction
            let response = ChatResponse<CurrentUserReaction>(uniqueId: request.uniqueId,
                                                             result: .init(messageId: request.messageId, reaction: cachedVersion),
                                                             subjectId: request.conversationId)
            chat?.delegate?.chatEvent(event: .reaction(.reaction(response)))
            chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: request.messageId)))
            return true
        }
        return false
    }

    func storeNewCountRequestMessageIds(_ messageIds: [Int]) {
        messageIds.forEach { messageId in
            reactions.append(.init(messageId: messageId))
        }
    }

    func countEvent(inMemoryMessageIds: [Int], uniqueId: String, conversationId: Int) {
        let list = listOfReactionCount(inMemoryMessageIds)
        if list.count > 0 {
            let response = ChatResponse<[ReactionCountList]>(uniqueId: uniqueId,
                                                             result: list,
                                                             subjectId: conversationId)
            chat?.delegate?.chatEvent(event: .reaction(.count(response)))
            list.forEach { item in
                chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: item.messageId ?? 0)))
            }
        }
    }

    func listOfReactionCount(_ messageIds: [Int]) -> [ReactionCountList] {
        messageIds
            .compactMap { messageId in
                ReactionCountList(messageId: messageId, reactionCounts: summary(for: messageId))
            }
    }

    /// Generate list of messageIds where they are available in memory.
    func inMemoryMessageIds(_ messageIds: [Int]) -> [Int] {
        let cachedMessageIds = reactions.map{$0.messageId}
        return messageIds
            .filter { requestMessageId in
                cachedMessageIds.contains(where: {$0 == requestMessageId} )
            }
    }

    /// Generate list of messageIds where they are not available in memory.
    func notInMemoryMessageIds(_ messageIds: [Int]) -> [Int] {
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

    func getOffset(_ request: RactionListRequest) -> Int {
        guard let index = indexOfMessageId(request.messageId) else { return 0 }
        let reacrionInMemory = reactions[index]
        let allStoredReactions = reacrionInMemory.details
        let byStickerFilter = allStoredReactions.filter({$0.reaction == request.sticker})

        let currentStoredInMemory = request.sticker == nil ? allStoredReactions : byStickerFilter
        let count = currentStoredInMemory.count

        let response = ChatResponse<ReactionList>(uniqueId: request.uniqueId,
                                                  result: .init(messageId: request.messageId, reactions: currentStoredInMemory),
                                                  subjectId: request.conversationId)
        chat?.delegate?.chatEvent(event: .reaction(.list(response)))
        chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: request.messageId)))

        return count
    }

    func onSummaryCount(_ response: ChatResponse<[ReactionCountList]>) {
        response.result?.forEach { listCount in
            let index = findOrCreateIndex(listCount.messageId ?? 0)
            reactions[index].summary = listCount.reactionCounts ?? []
            setUserReaction(listCount)
            chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: listCount.messageId ?? 0)))
        }
    }

    func setUserReaction(_ list: ReactionCountList) {
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
            chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: messageId)))
        }
    }

    func onReactionList(_ response: ChatResponse<ReactionList>) {
        if let messageId = response.result?.messageId,
           let index = indexOfMessageId(messageId),
           let reactions = response.result?.reactions {
            self.reactions[index].appendOrReplaceDetail(reactions: reactions)
            chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: messageId)))
        }
    }

    func onAdd(_ response: ChatResponse<ReactionMessageResponse>) {
        if let messageId = response.result?.messageId {
            let index = findOrCreateIndex(messageId)
            reactions[index].addOrReplaceSummaryCount(sticker: response.result?.reaction?.reaction ?? Sticker.unknown)
            setUserReaction(index: index, action: response.result)
            chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: messageId)))
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
        chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: messageId)))
    }

    func onDelete(_ response: ChatResponse<ReactionMessageResponse>) {
        guard let result = response.result, let index = indexOfMessageId(result.messageId) else { return }
        reactions[index].deleteSummaryCount(sticker: result.reaction?.reaction ?? Sticker.unknown)
        removeCurrentUserReaction(index: index, action: result)
        chat?.delegate?.chatEvent(event: .reaction(.inMemoryUpdate(messageId: result.messageId ?? 0)))
    }

    func removeCurrentUserReaction(index: Int, action: ReactionMessageResponse) {
        if chat?.userInfo?.id == action.reaction?.participant?.id {
            reactions[index].currentUserReaction = nil
        }
    }

    func setUserReaction(index: Int, action: ReactionMessageResponse?) {
        if chat?.userInfo?.id == action?.reaction?.participant?.id, let reaction = action?.reaction {
            reactions[index].currentUserReaction = reaction
        }
    }

    func findOrCreateIndex(_ messageId: Int) -> Int {
        if let index = indexOfMessageId(messageId) {
            return index
        } else {
            reactions.append(.init(messageId: messageId))
            return max(0, reactions.count - 1)
        }
    }

    func indexOfMessageId(_ messageId: Int?) -> Int? {
        reactions.firstIndex(where: { $0.messageId == messageId })
    }

    public func currentReaction(_ messageId: Int) -> Reaction? {
        guard let index = indexOfMessageId(messageId) else { return nil }
        return reactions[index].currentUserReaction
    }

    public func summary(for messageId: Int) -> [ReactionCount] {
        guard let index = indexOfMessageId(messageId) else { return [] }
        return reactions[index].summary
    }

    /// Clear in memory cache upon disconnect.
    public func invalidate() {
        reactions.removeAll()
    }
}
