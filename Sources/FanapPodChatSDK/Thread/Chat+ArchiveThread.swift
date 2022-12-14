//
// Chat+ArchiveThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestArchiveThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .archiveThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestUnArchiveThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .unarchiveThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onArchiveUnArchiveThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let threadId = chatMessage.subjectId else { return }
        cache.write(cacheType: .archiveUnarchiveAhread(chatMessage.type == .archiveThread, threadId))
        cache.save()
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: threadId))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .archiveThread)
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unarchiveThread)
    }
}
