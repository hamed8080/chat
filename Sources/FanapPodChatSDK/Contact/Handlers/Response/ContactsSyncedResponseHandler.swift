//
// ContactsSyncedResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class ContactsSyncedResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        CacheFactory.write(cacheType: .syncedContacts)
        CacheFactory.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .contactSynced)
    }
}
