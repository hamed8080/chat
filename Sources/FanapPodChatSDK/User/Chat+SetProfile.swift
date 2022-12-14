//
// Chat+SetProfile.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestSetProfile(_ req: UpdateChatProfile, _ completion: @escaping CompletionType<Profile>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onSetProfile(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let profile = try? JSONDecoder().decode(Profile.self, from: data) else { return }
        guard let callback: CompletionType<Profile> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: profile))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .setProfile)
    }
}
