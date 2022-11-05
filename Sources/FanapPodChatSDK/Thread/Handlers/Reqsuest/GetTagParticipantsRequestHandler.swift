//
// GetTagParticipantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class GetTagParticipantsRequestHandler {
    class func handle(_ req: GetTagParticipantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Conversation]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.id,
                                messageType: .getTagParticipants,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [Conversation], response.uniqueId, response.error)
        }
    }
}
