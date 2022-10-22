//
// AddParticipantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AddParticipantsRequestHandler {
    class func handle(_ req: [AddParticipantRequest],
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Conversation>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        guard let firstAddRequest = req.first else { return }
        let contactIds = firstAddRequest.contactIds
        chat.prepareToSendAsync(req: contactIds ?? req,
                                clientSpecificUniqueId: firstAddRequest.uniqueId,
                                subjectId: firstAddRequest.threadId,
                                messageType: .addParticipant,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Conversation, response.uniqueId, response.error)
        }
    }
}
