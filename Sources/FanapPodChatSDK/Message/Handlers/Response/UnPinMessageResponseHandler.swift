//
// UnPinMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class UnPinMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let pinResponse = try? JSONDecoder().decode(PinUnpinMessage.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .thread(.messageUnpin(threadId: chatMessage.subjectId, pinResponse)))
        CacheFactory.write(cacheType: .unpinMessage(pinResponse, chatMessage.subjectId))
        PSM.shared.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: pinResponse))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unpinMessage)
    }
}
