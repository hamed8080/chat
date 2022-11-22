//
// LeaveThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class LeaveThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let user = try? JSONDecoder().decode(User.self, from: data) else { return }

        chat.delegate?.chatEvent(event: .thread(.threadLeaveParticipant(user)))
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))

        guard let threadId = chatMessage.subjectId else { return }
        CacheFactory.write(cacheType: .leaveThread(threadId))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }

        callback(.init(uniqueId: chatMessage.uniqueId, result: user))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .leaveThread)
    }
}
