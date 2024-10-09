//
// Chat+CallsToJoin.swift
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
    /// A list of calls that is currnetly is running and you could join to them.
    /// - Parameters:
    ///   - request: List of threads that you are in and more filters.
    func getCallsToJoin(_ request: GetJoinCallsRequest) {
        prepareToSendAsync(req: request, type: .getCallsToJoin)
    }
}

// Response
extension ChatImplementation {
    func onJoinCalls(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Call]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callsToJoin(response)))
    }
}
