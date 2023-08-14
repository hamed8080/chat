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

    func count(_ request: RactionCountRequest) {
        chat.prepareToSendAsync(req: request, type: .reactionCount)
    }

    func get(_ request: RactionListRequest) {
        chat.prepareToSendAsync(req: request, type: .reactionList)
    }

    func add(_ request: AddReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .addReaction)
    }

    func replace(_ request: ReplaceReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .replaceReaction)
    }

    func delete(_ request: DeleteReactionRequest) {
        chat.prepareToSendAsync(req: request, type: .removeReaction)
    }

    func onReactionCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ReactionCountList]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.count(response)))
    }

    func onReactionList(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionList> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.list(response)))
    }

    func onAddReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.add(response)))
    }

    func onReplaceReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.reaplce(response)))
    }

    func onDeleteReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .reaction(.delete(response)))
    }
}
