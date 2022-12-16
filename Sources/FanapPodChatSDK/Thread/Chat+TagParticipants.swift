//
// Chat+TagParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestTagParticipants(_ req: GetTagParticipantsRequest, _ completion: @escaping CompletionType<[TagParticipant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onTagParticipants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[TagParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let tagParticipants = try? JSONDecoder().decode([TagParticipant].self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: tagParticipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getTagParticipants)
    }
}
