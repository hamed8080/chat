//
// Chat+CallsHistory.swift
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
    /// List of the call history.
    /// - Parameters:
    ///   - request: The request that contains offset and count and some other filters.
    func callsHistory(_ request: CallsHistoryRequest) {
        prepareToSendAsync(req: request, type: .getCalls)
    }
}

// Response
extension ChatImplementation {
    func onCallsHistory(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<[Call]> = asyncMessage.toChatResponse(asyncManager: asyncManager)
        response.contentCount = asyncMessage.chatMessage?.contentCount
        delegate?.chatEvent(event: .call(.history(response)))     
    }
}
