//
// Chat+CreateTag.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import Foundation

// Request
public extension Chat {
    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    ///   - completion: Response of the request if tag added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createTag(_ request: CreateTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCreateTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .tag(.createTag(response)))
        cache?.tag.insert(models: [response.result].compactMap { $0 })
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
