//
// Chat+CloseThread.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import Foundation

// Request
public extension Chat {
    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    ///   - completion: The id of the thread which closed.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func closeThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .closeThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCloseThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadClosed(response)))
        cache?.conversation.close(true, response.result ?? -1)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
