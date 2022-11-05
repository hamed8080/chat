//
// ActiveCallParticipantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ActiveCallParticipantsRequestHandler {
    class func handle(_ req: ActiveCallParticipantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[CallParticipant]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .activeCallParticipants,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [CallParticipant], response.uniqueId, response.error)
        }
    }
}
