//
// Chat+ChangeVideoCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestTurnOffVideoCall(_ req: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .turnOffVideoCall
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggleCamera()
    }

    func requestTurnOnVideoCall(_ req: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .turnOnVideoCall
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggleCamera()
    }
}

// Response
extension Chat {
    func onVideoCallChanged(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        delegate?.chatEvent(event: chatMessage.type == .turnOnVideoCall ? .call(.turnVideoOn(callParticipants)) : .call(.turnVideoOff(callParticipants)))
        guard let callback: CompletionType<[CallParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: callParticipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: chatMessage.type)
    }
}
