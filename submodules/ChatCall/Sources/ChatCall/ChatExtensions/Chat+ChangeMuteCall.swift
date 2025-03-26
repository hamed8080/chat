//
// Chat+ChangeMuteCall.swift
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
    /// Mute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone off.
    func muteCall(_ request: MuteCallRequest) {
        prepareToSendAsync(req: request, type: .muteCallParticipant)
        ChatCall.instance?.webrtc?.toggle()
    }

    /// UNMute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone on.
    func unmuteCall(_ request: UNMuteCallRequest) {
        prepareToSendAsync(req: request, type: .unmuteCallParticipant)
        ChatCall.instance?.webrtc?.toggle()
    }
}

// Response
extension ChatImplementation {
    func onMute(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantMute(response)))
    }

    func onUNMute(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantUnmute(response)))
    }
}
