//
// ReactionManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

public extension Chat {
    func reaction(_ request: UserReactionRequest) {
        if _internalInMemoryReaction?.reaction(request) == false {
            /// Featch current user Message reaction from the server
            prepareToSendAsync(req: request)
        }
    }

    func reactionCount(_ request: RactionCountRequest) {
        guard let tuple = _internalInMemoryReaction?.tupleOfMessageIds(request.messageIds) else { return }
        let newRquest = request
        newRquest.messageIds = tuple.notInMemory
        _internalInMemoryReaction?.countEvent(inMemoryMessageIds: tuple.inMemory, uniqueId: request.uniqueId, conversationId: request.conversationId)
        _internalInMemoryReaction?.storeNewCountRequestMessageIds(newRquest.messageIds)
        if newRquest.messageIds.isEmpty { return }
        prepareToSendAsync(req: newRquest)
    }

    func getReactions(_ request: RactionListRequest) {
        let allowedRequestOffset = _internalInMemoryReaction?.getOffset(request) ?? 0
        if  allowedRequestOffset <= request.offset {
            let newReq = request
            newReq.offset = allowedRequestOffset
            prepareToSendAsync(req: newReq)
        }
    }

    func addReaction(_ request: AddReactionRequest) {
        prepareToSendAsync(req: request)
    }

    func replaceReaction(_ request: ReplaceReactionRequest) {
        prepareToSendAsync(req: request)
    }

    func deleteReaction(_ request: DeleteReactionRequest) {
        prepareToSendAsync(req: request)
    }

    internal func onReactionCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ReactionCountList]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.count(response)))
        _internalInMemoryReaction?.onSummaryCount(response)
    }

    internal func onUserReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CurrentUserReaction> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.reaction(response)))
        _internalInMemoryReaction?.onUserReaction(response)
    }

    internal func onReactionList(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionList> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.list(response)))
        _internalInMemoryReaction?.onReactionList(response)
    }

    internal func onAddReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.add(response)))
        _internalInMemoryReaction?.onAdd(response)
    }

    internal func onReplaceReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.replace(response)))
        _internalInMemoryReaction?.onReplace(response)
    }

    internal func onDeleteReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .reaction(.delete(response)))
        _internalInMemoryReaction?.onDelete(response)
    }
}
