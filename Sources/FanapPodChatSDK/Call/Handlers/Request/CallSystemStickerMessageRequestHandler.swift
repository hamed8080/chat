//
// CallSystemStickerMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CallSystemStickerMessageRequestHandler {
    class func handle(_ req: CallStickerRequest,
                      _ chat: Chat,
                      _ completion: CompletionType<StickerResponse>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion?(response.result as? StickerResponse, response.uniqueId, response.error)
        }
    }
}
