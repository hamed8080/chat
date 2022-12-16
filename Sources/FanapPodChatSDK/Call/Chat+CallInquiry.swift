//
// Chat+CallInquiry.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCallInquiry(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<[CallParticipant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .callInquiry
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallInquiry(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[CallParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callParticipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callInquiry)
    }
}
