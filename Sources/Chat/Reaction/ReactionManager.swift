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
    private var store: ReactionsStore? { chat.coordinator.reaction }
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func reaction(_ request: UserReactionRequest) {
        if let response = store?.reaction(request) {
            emitEvent(.reaction(.reaction(response)))
        } else {
            chat.prepareToSendAsync(req: request, type: .getReaction)
        }
    }
    
    func count(_ request: ReactionCountRequest) {
        guard let store = store else { return }
        let tuple = store.tupleOfMessageIds(request.messageIds)
        var newRquest = request
        newRquest.messageIds = tuple.notInMemory
        if let response = store.count(inMemoryMessageIds: tuple.inMemory, request: request) {
            emitEvent(.reaction(.count(response)))
        }
        store.storeNewCountRequestMessageIds(newRquest.messageIds)
        if newRquest.messageIds.isEmpty { return }
        chat.prepareToSendAsync(req: newRquest, type: .reactionCount)
        
        let typeCode = request.toTypeCode(chat)
        
        let reactionCache = cache?.reactionCount
        Task { @MainActor in
            if let models = reactionCache?.fetch(request.messageIds) {
                let reactionCounts = models.compactMap({$0.codable})
                let response = request.toCountResponse(models: reactionCounts, typeCode: typeCode)
                emitEvent(event: .reaction(.count(response)))
            }
        }
    }
    
    func get(_ request: ReactionListRequest) {
        if request.sticker == nil {
            getAllDetail(request)
        } else {
            getStickerDetail(request)
        }
    }
    
    private func getAllDetail(_ request: ReactionListRequest) {
        if let response = store?.getAllDetailOffset(request) {
            emitEvent(.reaction(.list(response)))
        } else {
            store?.listRequests[request.uniqueId] = request
            chat.prepareToSendAsync(req: request, type: .reactionList)
        }
    }
    
    private func getStickerDetail(_ request: ReactionListRequest) {
        if let response = store?.getStickerOffset(request), response.result?.reactions?.count ?? 0 >= request.count {
            emitEvent(.reaction(.list(response)))
        } else {
            store?.listRequests[request.uniqueId] = request
            chat.prepareToSendAsync(req: request, type: .reactionList)
        }
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
    
    func allowedReactions(_ request: ConversationAllowedReactionsRequest) {
        chat.prepareToSendAsync(req: request, type: .allowedReactions)
    }
    
    func customizeReactions(_ request: ConversationCustomizeReactionsRequest) {
        chat.prepareToSendAsync(req: request, type: .customizeReactions)
    }
    
    func onReactionCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ReactionCountList]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        cache?.reactionCount?.insert(models: copies)
        emitEvent(.reaction(.count(response)))
        store?.onSummaryCount(response)
    }
    
    func onUserReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CurrentUserReaction> = asyncMessage.toChatResponse()
        emitEvent(.reaction(.reaction(response)))
        store?.onUserReaction(response)
    }
    
    func onReactionList(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionList> = asyncMessage.toChatResponse()
        emitEvent(.reaction(.list(response)))
        store?.onReactionList(response)
    }
    
    func onAddReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(model: response.toCacheModel(action: .add, myId: chat.userInfo?.id))
        emitEvent(.reaction(.add(response)))
        store?.onAdd(response)
    }
    
    func onReplaceReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        emitEvent(.reaction(.replace(response)))
        cache?.reactionCount?.setReactionCount(model: response.toCacheModel(action: .replace, myId: chat.userInfo?.id))
        store?.onReplace(response)
    }
    
    func onDeleteReaction(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<ReactionMessageResponse> = asyncMessage.toChatResponse()
        cache?.reactionCount?.setReactionCount(model: response.toCacheModel(action: .delete, myId: chat.userInfo?.id))
        emitEvent(.reaction(.delete(response)))
        store?.onDelete(response)
    }
    
    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        if let messageId = response.result?.id {
            store?.onNewMessage(messageId: messageId)
        }
    }
    
    func onAllowedReactions(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<AllowedReactionsResponse> = asyncMessage.toChatResponse()
        emitEvent(.reaction(.allowedReactions(response)))
    }
    
    func onCustomizeReactions(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CustomizeReactionsResponse> = asyncMessage.toChatResponse()
        emitEvent(.reaction(.customizeReactions(response)))
    }
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        chat.delegate?.chatEvent(event: event)
    }
}
