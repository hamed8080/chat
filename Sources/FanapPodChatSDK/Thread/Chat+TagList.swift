//
// Chat+TagList.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// List of Tags.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of request if you want to set a specific one.
    ///   - completion: List of tags.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func tagList(_ uniqueId: String? = nil, completion: @escaping CompletionType<[Tag]>, uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest(uniqueId: uniqueId)
        req.chatMessageType = .tagList
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onTags(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Tag]> = asyncMessage.toChatResponse(context: persistentManager.context)
        cache?.write(cacheType: .tags(response.result ?? []))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
