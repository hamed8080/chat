//
// Chat+EditTag.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    ///   - completion: Response of the request if tag edited successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func editTag(_ request: EditTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onEditTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .tag(.editTag(response)))
        if let tag = response.result {
            cache?.write(cacheType: .tags([tag]))
            cache?.save()
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
