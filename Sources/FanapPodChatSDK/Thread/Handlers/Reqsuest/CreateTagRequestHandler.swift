//
// CreateTagRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CreateTagRequestHandler {
    class func handle(_ req: CreateTagRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Tag>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .createTag,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Tag, response.uniqueId, response.error)
        }
    }
}
