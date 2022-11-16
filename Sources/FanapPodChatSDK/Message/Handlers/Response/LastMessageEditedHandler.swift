//
// LastMessageEditedHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class LastMessageEditedHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let thread = try? JSONDecoder().decode(Conversation.self, from: data) else { return }

        chat.delegate?.chatEvent(event: .thread(.lastMessageEdited(thread: thread)))
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        CacheFactory.write(cacheType: .threads([thread]))
        CacheFactory.save()
    }
}
