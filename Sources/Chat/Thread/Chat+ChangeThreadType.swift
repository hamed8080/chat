//
// Chat+ChangeThreadType.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    ///   - completion: Response of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func changeThreadType(_ request: ChangeThreadTypeRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .changeThreadType, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onChangeThreadType(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadRemovedFrom(.init(uniqueId: response.uniqueId, result: response.result?.id))))
        cache?.conversation.changeThreadType(response.result)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
