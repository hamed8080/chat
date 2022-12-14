//
// Chat+BlockedContacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestBlockedContacts(_ req: BlockedListRequest, _ completion: @escaping CompletionType<[BlockedContact]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[BlockedContact]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onBlockedContacts(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let blockedContacts = try? JSONDecoder().decode([BlockedContact].self, from: data) else { return }
        guard let callback: CompletionType<[BlockedContact]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: blockedContacts))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getBlocked)
    }
}
