//
// DeleteThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class DeleteThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let threadId = chatMessage.subjectId else { return }
        var participant: Participant?
        if let data = chatMessage.content?.data(using: .utf8) {
            participant = try? JSONDecoder().decode(Participant.self, from: data)
            chat.delegate?.chatEvent(event: .thread(.threadDeleted(threadId: threadId, participant: participant)))
            chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        }
        CacheFactory.write(cacheType: .deleteThreads([threadId]))
        CacheFactory.save()
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deleteThread)
    }
}
