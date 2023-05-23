//
// ChatImplementation+LeaveThread.swift
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
    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    ///   - completion: The response of the left thread..
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func leaveThread(_ request: LeaveThreadRequest, completion: @escaping CompletionType<User>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .leaveThread, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onLeaveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadLeaveParticipant(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        cache?.participant?.delete([Participant(id: response.result?.id)])
        if response.result?.id == userInfo?.id, let threadId = response.subjectId {
            cache?.conversation?.delete(threadId)
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
