//
// Chat+ChangeVideoCall.swift
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
    /// Turn on the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera on.
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .turnOnVideoCall)
        ChatCall.instance?.webrtc?.toggleCamera()
    }

    /// Turn off the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera off.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .turnOffVideoCall)
        ChatCall.instance?.webrtc?.toggleCamera()
    }
}

// Response
extension ChatImplementation {
    func onVideoTurnedOn(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.turnVideoOn(response)))
    }

    func onVideoTurnedOff(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.turnVideoOff(response)))
    }
}
