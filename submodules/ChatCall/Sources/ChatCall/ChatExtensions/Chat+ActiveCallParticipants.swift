//
// Chat+ActiveCallParticipants.swift
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
    /// List of active call participants during the call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func activeCallParticipants(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .activeCallParticipants)
    }
}

// Response
extension ChatImplementation {
    func onActiveCallParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.activeCallParticipants(response)))
    }
}
