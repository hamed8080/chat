//
// Chat+CreateTag.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
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
        if let tag = response.result {
            cache?.write(cacheType: .tags([tag]))
            cache?.save()
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
