//
// Chat+EndCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore
import Async

// Request
public extension ChatImplementation {
    /// To terminate a call.
    /// - Parameters:
    ///   - request: A request with a callId to finish the current call.
    func endCall(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .endCallRequest)
    }
}

// Response
extension ChatImplementation {
    func onCallEnded(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Int> = asyncMessage.toChatResponse()
        ChatCall.instance?.callState = .ended
        response.result = response.subjectId
        delegate?.chatEvent(event: .call(.callEnded(response)))
        ChatCall.instance?.webrtc?.clearResourceAndCloseConnection()
        ChatCall.instance?.webrtc = nil
    }
}
