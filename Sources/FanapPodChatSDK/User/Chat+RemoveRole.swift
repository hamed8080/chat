//
// Chat+RemoveRole.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestRemoveRole(_ req: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .removeRoleFromUser
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRemveUserRoles(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let threadId = chatMessage.subjectId else { return }
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: threadId)))
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let usersAndRoles = try? JSONDecoder().decode([UserRole].self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadUserRole(threadId: threadId, roles: usersAndRoles)))
        guard let callback: CompletionType<[UserRole]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: usersAndRoles))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeRoleFromUser)
    }
}
