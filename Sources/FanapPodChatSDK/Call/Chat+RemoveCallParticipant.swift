//
// Chat+RemoveCallParticipant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
// Request
extension Chat {
    func requestRemoveCallParticipant(_ req: RemoveCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRemoveCallParticipant(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callParticipantsRemoved(callParticipants)))
        guard let callback: CompletionType<[CallParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callParticipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeCallParticipant)
        callParticipants.forEach { callParticipant in
            webrtc?.removeCallParticipant(callParticipant)
        }
    }
}
