//
// Chat+BlockContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Contacts
import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func blockContact(_ request: BlockRequest, completion: @escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onBlockContact(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BlockedContact> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .contact(.blocked(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
