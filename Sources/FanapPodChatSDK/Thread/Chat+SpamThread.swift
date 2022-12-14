//
// Chat+SpamThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestSpamThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<BlockedContact>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .spamPvThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onSpamThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<BlockedContact> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let blockedUser = try? JSONDecoder().decode(BlockedContact.self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: blockedUser))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .spamPvThread)
    }
}
