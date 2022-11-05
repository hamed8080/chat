//
// ThreadParticipantsResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class ThreadParticipantsResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else { return }
        chat.delegate?.chatEvent(event: .thread(.threadParticipantsListChange(threadId: chatMessage.subjectId, participants)))
        CacheFactory.write(cacheType: .participants(participants, chatMessage.subjectId))
        PSM.shared.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: participants, contentCount: chatMessage.contentCount ?? 0))

        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .threadParticipants)
    }
}
