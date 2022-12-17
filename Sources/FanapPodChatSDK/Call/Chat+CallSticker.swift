//
// Chat+CallSticker.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Send a sticker during the call..
    /// - Parameters:
    ///   - request: The callId and a sticker.
    ///   - completion: Response of the send.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func sendCallSticker(_ request: CallStickerRequest, _ completion: CompletionType<StickerResponse>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallSticker(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<StickerResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.sticker(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
