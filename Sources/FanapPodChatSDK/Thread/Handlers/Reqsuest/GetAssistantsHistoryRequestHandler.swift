//
// GetAssistantsHistoryRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public class GetAssistantsHistoryRequestHandler {
    class func handle(_ chat: Chat,
                      _ completion: @escaping CompletionType<[AssistantAction]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        let req = BaseRequest()
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .getAssistantHistory,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [AssistantAction], response.uniqueId, response.error)
        }
    }
}
