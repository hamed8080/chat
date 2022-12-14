//
// Chat+DeleteThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestDeleteThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .deleteThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onDeleteThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let threadId = chatMessage.subjectId else { return }
        var participant: Participant?
        if let data = chatMessage.content?.data(using: .utf8) {
            participant = try? JSONDecoder().decode(Participant.self, from: data)
            delegate?.chatEvent(event: .thread(.threadDeleted(threadId: threadId, participant: participant)))
            delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        }
        cache.write(cacheType: .deleteThreads([threadId]))
        cache.save()
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: threadId))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deleteThread)
    }
}
