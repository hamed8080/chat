//
// ChatImplementation+MuteThread.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of mute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func muteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .muteThread, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unmute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unmuteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .unmuteThread, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onMuteUnMuteThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        if asyncMessage.chatMessage?.type == .muteThread {
            delegate?.chatEvent(event: .thread(.threadMute(response)))
        } else if asyncMessage.chatMessage?.type == .unmuteThread {
            delegate?.chatEvent(event: .thread(.threadUnmute(response)))
        }
        cache?.conversation?.mute(asyncMessage.chatMessage?.type == .muteThread, response.subjectId)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
