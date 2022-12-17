//
// Chat+ChangeMuteCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Mute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone off.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func muteCall(_ request: MuteCallRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggle()
    }

    /// UNMute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone on.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unmuteCall(_ request: UNMuteCallRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        webrtc?.toggle()
    }
}

// Response
extension Chat {
    func onMuteChanged(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: asyncMessage.chatMessage?.type == .muteCallParticipant ? .call(.callParticipantMute(response)) : .call(.callParticipantUnmute(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
