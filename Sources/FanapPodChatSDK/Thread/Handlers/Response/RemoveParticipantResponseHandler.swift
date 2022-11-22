//
// RemoveParticipantResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class RemoveParticipantResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else { return }
        CacheFactory.write(cacheType: .removeParticipants(participants: participants, threadId: chatMessage.subjectId))
        CacheFactory.save()
        chat.delegate?.chatEvent(event: .thread(.threadRemoveParticipants(participants)))
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: participants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeParticipant)
    }
}
