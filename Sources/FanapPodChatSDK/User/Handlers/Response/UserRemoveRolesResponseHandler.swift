//
// UserRemoveRolesResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class UserRemoveRolesResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let threadId = chatMessage.subjectId else { return }
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: threadId)))

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let usersAndRoles = try? JSONDecoder().decode([UserRole].self, from: data) else { return }
        chat.delegate?.chatEvent(event: .thread(.threadUserRole(threadId: threadId, roles: usersAndRoles)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: usersAndRoles))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeRoleFromUser)
    }
}
