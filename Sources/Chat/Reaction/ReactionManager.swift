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

final class ReactionManager: ReactionProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func reaction(_ request: UserReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .getReaction)
    }

    func count(_ request: RactionCountRequest) {
        chat.prepareToSendAsync(req: request, type: .reactionCount)
        cache?.reactionCount?.fetch(request.messageIds) { [weak self] reactionCountList in
            let reactionCountListModels = reactionCountList.map { $0.codable }
            self?.chat.responseQueue.async {
                let response = ChatResponse(uniqueId: request.uniqueId, result: reactionCountListModels, hasNext: false, cache: true)
                self?.chat.delegate?.chatEvent(event: .reaction(.count(response)))
            }
        }
    }

    func get(_ request: RactionListRequest) {
        chat.prepareToSendAsync(req: request, type: .reactionList)
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
        cache?.reactionCount?.insert(models: response.result ?? [])
        chat.delegate?.chatEvent(event: .reaction(.count(response)))
    }

    func onUserReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CurrentUserReaction> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.reaction(response)))
    }

    func onReactionList(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionList> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.list(response)))
    }

    func onAddReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .increase)
        chat.delegate?.chatEvent(event: .reaction(.add(response)))
    }

    func onReplaceReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.replace(response)))
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .increase)
    }

    func onDeleteReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(messageId: response.result?.messageId, reaction: response.result?.reaction?.reaction, action: .decrease)
        chat.delegate?.chatEvent(event: .reaction(.delete(response)))
    }
}
