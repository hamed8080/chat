//
// BlockAssistnatRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public class BlockAssistantRequestHandler {
    class func handle(_ req: BlockUnblockAssistantRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Assistant]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [Assistant], response.uniqueId, response.error)
        }
    }
}
