//
// Chat+CallRecording.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore
import ChatModels
import Async


// Request
public extension ChatImplementation {
    /// A request to start recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func startRecording(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .startRecording)
    }

    /// A request to stop recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func stopRecording(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .stopRecording)
    }
}

// Response
extension ChatImplementation {
    func onCallRecordingStarted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.startCallRecording(response)))
    }

    func onCallRecordingStopped(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.stopCallRecording(response)))
    }
}
