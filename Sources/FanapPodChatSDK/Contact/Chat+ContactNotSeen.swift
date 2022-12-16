//
// Chat+ContactNotSeen.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestContactNotSeen(_ req: NotSeenDurationRequest, _ completion: @escaping CompletionType<[UserLastSeenDuration]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<ContactNotSeenDurationRespoonse>) in
            completion(ChatResponse(uniqueId: req.uniqueId, result: response.result?.notSeenDuration, error: response.error))
        }
    }
}

extension Chat {
    func onContactNotSeen(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<ContactNotSeenDurationRespoonse> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let contacts = try? JSONDecoder().decode(ContactNotSeenDurationRespoonse.self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: contacts))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getNotSeenDuration)
    }
}
