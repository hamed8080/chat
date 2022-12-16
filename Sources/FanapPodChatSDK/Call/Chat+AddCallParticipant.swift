//
// Chat+AddCallParticipant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestAddCallParticipant(_ req: AddCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onJoinCallParticipant(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callPartitipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callParticipantJoined(callPartitipants)))
        guard let callback: CompletionType<[CallParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callPartitipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callParticipantJoined)
    }
}
