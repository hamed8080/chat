//
// AddTagParticipantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AddTagParticipantsRequestHandler {
    class func handle(_ req: AddTagParticipantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[TagParticipant]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.threadIds,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.tagId,
                                messageType: .addTagParticipants,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [TagParticipant], response.uniqueId, response.error)
        }
    }
}
