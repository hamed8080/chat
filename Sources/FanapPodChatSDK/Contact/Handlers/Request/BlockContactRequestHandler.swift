//
// BlockContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation

class BlockContactRequestHandler {
    class func handle(_ req: BlockRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<BlockedContact>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .block,
                                uniqueIdResult: uniqueIdResult,
                                completion: { response in
                                    completion(response.result as? BlockedContact, response.uniqueId, response.error)
                                })
    }
}
