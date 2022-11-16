//
// DeleteTagRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class DeleteTagRequestHandler {
    class func handle(_ req: DeleteTagRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Tag>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Tag, response.uniqueId, response.error)
        }
    }
}
