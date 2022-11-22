//
// AddParticipantResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class AddParticipantResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        CacheFactory.write(cacheType: .participants(conversation.participants, conversation.id))
        CacheFactory.save()
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        chat.delegate?.chatEvent(event: .thread(.threadAddParticipants(thread: conversation, conversation.participants)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: conversation))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .addParticipant)
    }
}
