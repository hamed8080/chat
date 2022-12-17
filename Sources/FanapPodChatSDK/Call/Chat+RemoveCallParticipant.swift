//
// Chat+RemoveCallParticipant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
// Request
public extension Chat {
    /// Remove a participant from a call if you have access.
    /// - Parameters:
    ///   - request: The request that contains a callId and llist of user to remove from a call.
    ///   - completion: List of removed participants from a call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeCallPartcipant(_ request: RemoveCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRemoveCallParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantsRemoved(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
        response.result?.forEach { callParticipant in
            webrtc?.removeCallParticipant(callParticipant)
        }
    }
}
