//
// Chat+PinThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of pin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func pinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .pinThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unpin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unpinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .unpinThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onPinUnPinThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        if asyncMessage.chatMessage?.type == .pinThread {
            delegate?.chatEvent(event: .thread(.threadPin(response)))
        } else if asyncMessage.chatMessage?.type == .unpinThread {
            delegate?.chatEvent(event: .thread(.threadUnpin(response)))
        }
        cache?.write(cacheType: .pinUnpinThread(response.subjectId ?? 0))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
