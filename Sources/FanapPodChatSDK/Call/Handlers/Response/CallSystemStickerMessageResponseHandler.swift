//
// CallSystemStickerMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CallSystemStickerMessageResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let sticker = try? JSONDecoder().decode(StickerResponse.self, from: data) else { return }
        sticker.callId = chatMessage.subjectId
        chat.delegate?.chatEvent(event: .call(.sticker(sticker)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: sticker))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callStickerSystemMessage)
    }
}
