//
// Chat+LeaveThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestLeaveThread(_ req: LeaveThreadRequest, _ completion: @escaping CompletionType<User>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onLeaveThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let user = try? JSONDecoder().decode(User.self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadLeaveParticipant(user)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        guard let threadId = chatMessage.subjectId else { return }
        cache.write(cacheType: .leaveThread(threadId))
        cache.save()
        guard let callback: CompletionType<User> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: user))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .leaveThread)
    }
}
