//
// Chat+CallSticker.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCallSticker(_ req: CallStickerRequest, _ completion: CompletionType<StickerResponse>? = nil, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallSticker(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let sticker = try? JSONDecoder().decode(StickerResponse.self, from: data) else { return }
        sticker.callId = chatMessage.subjectId
        delegate?.chatEvent(event: .call(.sticker(sticker)))
        guard let callback: CompletionType<StickerResponse> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: sticker))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callStickerSystemMessage)
    }
}
