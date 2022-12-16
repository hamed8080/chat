//
// Chat+RenewCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestRenewCall(_ req: RenewCallRequest, _ completion: @escaping CompletionType<CreateCall>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRenewCall(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<CreateCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: createCall))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .renewCallRequest)
    }
}
