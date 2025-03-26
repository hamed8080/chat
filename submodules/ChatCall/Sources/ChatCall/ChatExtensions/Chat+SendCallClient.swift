//
// Chat+SendCallClient.swift
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
    /// A request that shows some errors has happened on the client side during the call for example maybe the user doesn't have access to the camera when trying to turn it on.
    /// - Parameters:
    ///   - request: The code of the error and a callId.
    func sendCallClientError(_ request: CallClientErrorRequest) {
        prepareToSendAsync(req: request, type: .callClientErrors)
    }
}

// Response
extension ChatImplementation {
    func onCallError(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CallError> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callError(response)))
    }
}
