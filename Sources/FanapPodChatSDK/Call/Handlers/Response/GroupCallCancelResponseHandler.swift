//
// GroupCallCancelResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class GroupCallCancelResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard var cancelGroupCall = try? JSONDecoder().decode(CancelGroupCall.self, from: data) else { return }
        cancelGroupCall.callId = chatMessage.subjectId
        chat.delegate?.chatEvent(event: .call(.groupCallCanceled(cancelGroupCall)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: cancelGroupCall))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .cancelGroupCall)
    }
}
