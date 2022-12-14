//
// Chat+CloseThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCloseThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .closeThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCloseThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let threadId = chatMessage.subjectId else { return }
        delegate?.chatEvent(event: .thread(.threadClosed(threadId: threadId)))
        cache.write(cacheType: .threads([.init(id: threadId)]))
        cache.save()
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: threadId))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .closeThread)
    }
}
