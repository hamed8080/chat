//
// Chat+DeleteThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    ///   - completion: Result of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .deleteThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onDeleteThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadDeleted(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        cache?.conversation?.delete(response.subjectId ?? -1)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
