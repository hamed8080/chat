//
// Chat+ThreadNamePublic.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestIsThreadNamePublic(_ req: IsThreadNamePublicRequest, _ completion: @escaping CompletionType<String>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onIsThreadNamePublic(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<PublicThreadNameAvailableResponse> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let thread = try? JSONDecoder().decode(PublicThreadNameAvailableResponse.self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: thread))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .isNameAvailable)
    }
}
