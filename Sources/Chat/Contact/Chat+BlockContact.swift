//
// Chat+BlockContact.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Contacts
import Foundation

// Request
public extension Chat {
    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func blockContact(_ request: BlockRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    ///   - completion: Reponse of before blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unBlockContact(_ request: UnBlockRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onBlockUnBlockContact(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Contact> = asyncMessage.toChatResponse()
        cache?.contact.block(asyncMessage.chatMessage?.type == .block, response.result?.id)
        delegate?.chatEvent(event: .contact(.blocked(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
