//
// StartCallRecordingRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class StartCallRecordingRequestHandler {
    class func handle(_ req: StartCallRecordingRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Participant>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .startRecording,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Participant, response.uniqueId, response.error)
        }
    }
}
