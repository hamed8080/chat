//
// AddCallParticipantRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AddCallParticipantRequestHandler {
    class func handle(_ req: AddCallParticipantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[CallParticipant]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .addCallParticipant,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [CallParticipant], response.uniqueId, response.error)
        }
    }
}
