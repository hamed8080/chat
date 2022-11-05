//
// UNMuteCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UNMuteCallRequestHandler {
    class func handle(_ req: UNMuteCallRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[CallParticipant]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.userIds,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .unmuteCallParticipant,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [CallParticipant], response.uniqueId, response.error)
        }
    }
}
