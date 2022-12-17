//
// Chat+AddCallParticipant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Add a new participant to a thread during the call.
    /// - Parameters:
    ///   - request: A List of people with userNames or contactIds beside a callId.
    ///   - completion: A list of participants has been added to the current call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addCallPartcipant(_ request: AddCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onJoinCallParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantJoined(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
