//
// Chat+UnBlockContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestUnBlockContact(_ req: UnBlockRequest, _ completion: @escaping CompletionType<BlockedContact>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onUnBlockContact(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let blockedResult = try? JSONDecoder().decode(BlockedContact.self, from: data) else { return }
        guard let callback: CompletionType<BlockedContact> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: blockedResult))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unblock)
    }
}
