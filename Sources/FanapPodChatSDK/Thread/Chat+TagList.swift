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
    ///   - cacheResponse: List of cached tags.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func tagList(_ uniqueId: String? = nil, completion: @escaping CompletionType<[Tag]>, cacheResponse: CacheResponseType<[Tag]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest(uniqueId: uniqueId)
        req.chatMessageType = .tagList
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        let tags = cache?.tag?.getTags()
        cacheResponse?(ChatResponse(uniqueId: req.uniqueId, result: tags?.map(\.codable)))
    }
}

// Response
extension Chat {
    func onTags(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Tag]> = asyncMessage.toChatResponse()
        cache?.tag?.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
