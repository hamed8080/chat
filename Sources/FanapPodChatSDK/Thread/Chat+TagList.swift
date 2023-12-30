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
    func tagList(_ uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0, completion: @escaping CompletionType<[Tag]>, cacheResponse: CacheResponseType<[Tag]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
        req.chatMessageType = .tagList
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onTags(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Tag]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
