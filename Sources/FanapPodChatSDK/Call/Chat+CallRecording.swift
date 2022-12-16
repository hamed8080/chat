//
// Chat+CallRecording.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestStartRecording(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Participant>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .startRecording
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestStopRecording(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Participant>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .stopRecording
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallRecordingChanged(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let participant = try? JSONDecoder().decode(Participant.self, from: data) else { return }
        delegate?.chatEvent(event: chatMessage.type == .startRecording ? .call(.startCallRecording(participant)) : .call(.stopCallRecording(participant)))
        guard let callback: CompletionType<Participant> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: participant))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: chatMessage.type)
    }
}
