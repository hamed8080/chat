//
// EditTagRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class EditTagRequestHandler {
    class func handle(_ req: EditTagRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Tag>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.id,
                                messageType: .editTag,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Tag, response.uniqueId, response.error)
        }
    }
}
