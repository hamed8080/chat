//
// UNArchiveThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class UNArchiveThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let threadId = chatMessage.subjectId else { return }
        CacheFactory.write(cacheType: .archiveUnarchiveAhread(false, threadId))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unarchiveThread)
    }
}
