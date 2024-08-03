//
// ReactionManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import ChatExtensions

final class ReactionManager: ReactionProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }
    let inMemoryReaction: InMemoryReactionProtocol
    var _internalInMemoryReaction: InMemoryReaction? { inMemoryReaction as? InMemoryReaction }

    init(chat: ChatInternalProtocol) {
        self.chat = chat
        inMemoryReaction = chat.coordinator.reaction
    }

    func reaction(_ request: UserReactionRequest) {
        if _internalInMemoryReaction?.reaction(request) == false {
            /// Featch current user Message reaction from the server
            chat.prepareToSendAsync(req: request, type: .getReaction)
        }
    }

    func count(_ request: ReactionCountRequest) {
        guard let tuple = _internalInMemoryReaction?.tupleOfMessageIds(request.messageIds) else { return }
        var newRquest = request
        newRquest.messageIds = tuple.notInMemory
        _internalInMemoryReaction?.countEvent(inMemoryMessageIds: tuple.inMemory, uniqueId: request.uniqueId, conversationId: request.conversationId)
        _internalInMemoryReaction?.storeNewCountRequestMessageIds(newRquest.messageIds)
        if newRquest.messageIds.isEmpty { return }
        chat.prepareToSendAsync(req: newRquest, type: .reactionCount)
    }

    func get(_ request: ReactionListRequest) {
        //Creating and inserting an empty slot to the reactions array is essential if there is a connection disruption.

        var allowedRequestOffset = 0
        if let lastStoredOffset = _internalInMemoryReaction?.getOffset(request) {
            allowedRequestOffset = lastStoredOffset
        } else {
            _internalInMemoryReaction?.createEmptySlot(messageId: request.messageId)
        }
        if  allowedRequestOffset <= request.offset || request.sticker == nil {
            var newReq = request
            newReq.offset = request.sticker == nil ? request.offset : allowedRequestOffset
            chat.prepareToSendAsync(req: newReq, type: .reactionList)
        }
    }

    func add(_ request: AddReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .addReaction)
    }

    func replace(_ request: ReplaceReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .replaceReaction)
        cache?.reactionCount?.setReactionCount(messageId: request.messageId, reaction: request.reaction, action: .decrease)
    }

    func delete(_ request: DeleteReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .removeReaction)
    }

    func onReactionCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ReactionCountList]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        cache?.reactionCount?.insert(models: copies)
        chat.delegate?.chatEvent(event: .reaction(.count(response)))
        _internalInMemoryReaction?.onSummaryCount(response)
    }

    func onUserReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CurrentUserReaction> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.reaction(response)))
        _internalInMemoryReaction?.onUserReaction(response)
    }

    func onReactionList(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionList> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.list(response)))
        _internalInMemoryReaction?.onReactionList(response)
    }

    func onAddReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .increase)
        chat.delegate?.chatEvent(event: .reaction(.add(response)))
        _internalInMemoryReaction?.onAdd(response)
    }

    func onReplaceReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.replace(response)))
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .increase)
        _internalInMemoryReaction?.onReplace(response)
    }

    func onDeleteReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .decrease)
        chat.delegate?.chatEvent(event: .reaction(.delete(response)))
        _internalInMemoryReaction?.onDelete(response)
    }

    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        if let messageId = response.result?.id {
            _internalInMemoryReaction?.onNewMessage(messageId: messageId)
        }
    }
}
