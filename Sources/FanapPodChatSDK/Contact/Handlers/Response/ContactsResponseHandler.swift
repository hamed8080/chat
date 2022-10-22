//
// ContactsResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class ContactsResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let contacts = try? JSONDecoder().decode([Contact].self, from: data) else { return }
        CacheFactory.write(cacheType: .casheContacts(contacts))
        PSM.shared.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: contacts, contentCount: chatMessage.contentCount ?? contacts.count))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getContacts)
    }
}
