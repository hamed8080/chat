//
// Chat+ChangeVideoCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Turn on the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera on.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .turnOnVideoCall
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggleCamera()
    }

    /// Turn off the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera off.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .turnOffVideoCall
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggleCamera()
    }
}

// Response
extension Chat {
    func onVideoCallChanged(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: asyncMessage.chatMessage?.type == .turnOnVideoCall ? .call(.turnVideoOn(response)) : .call(.turnVideoOff(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
