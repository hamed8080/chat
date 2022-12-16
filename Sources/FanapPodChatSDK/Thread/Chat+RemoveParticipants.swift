//
// Chat+RemoveParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestRemoveParticipants(_ req: RemoveParticipantsRequest, _ completion: @escaping CompletionType<[Participant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRemoveParticipants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else { return }
        cache.write(cacheType: .removeParticipants(participants: participants, threadId: chatMessage.subjectId))
        cache.save()
        delegate?.chatEvent(event: .thread(.threadRemoveParticipants(participants)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        guard let callback: CompletionType<[Participant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: participants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeParticipant)
    }
}
