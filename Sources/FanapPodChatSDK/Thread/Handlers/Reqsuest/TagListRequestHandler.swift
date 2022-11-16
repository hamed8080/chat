//
// TagListRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class TagListRequestHandler {
    class func handle(_ uniqueId: String? = nil,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Tag]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        let req = BareChatSendableRequest(uniqueId: uniqueId)
        req.chatMessageType = .tagList
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [Tag], response.uniqueId, response.error)
        }
    }
}
