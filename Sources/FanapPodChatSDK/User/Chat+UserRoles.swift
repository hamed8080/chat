//
// Chat+CurrentUserRoles.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestSetRoles(_ req: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .setRuleToUser
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestCurrentUserRoles(_ req: GeneralSubjectIdRequest,
                                 _ completion: @escaping CompletionType<[Roles]>,
                                 _ cacheResponse: CacheResponseType<[Roles]>? = nil,
                                 _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .getCurrentUserRoles
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        cache.get(useCache: cacheResponse != nil, cacheType: .cureentUserRoles(req.subjectId), completion: cacheResponse)
    }
}

// Response
extension Chat {
    func onUserRoles(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let userRoles = try? JSONDecoder().decode([Roles].self, from: data) else { return }
        delegate?.chatEvent(event: .user(.roles(userRoles, id: chatMessage.subjectId)))
        cache.write(cacheType: .currentUserRoles(userRoles, chatMessage.subjectId))
        cache.save()
        guard let callback: CompletionType<[Roles]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: userRoles))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getCurrentUserRoles)
    }
}
