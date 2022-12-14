//
// Chat+AddParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestAddParticipant(_ req: AddParticipantRequest, _ completion: @escaping CompletionType<Conversation>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAddParticipant(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        cache.write(cacheType: .participants(conversation.participants, conversation.id))
        cache.save()
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        delegate?.chatEvent(event: .thread(.threadAddParticipants(thread: conversation, conversation.participants)))
        guard let callback: CompletionType<Conversation> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: conversation))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .addParticipant)
    }
}
