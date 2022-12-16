//
// Chat+MessagSeenByPartcipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestMessageSeenByParticipants(_ req: MessageSeenByUsersRequest, _ completion: @escaping CompletionType<[Participant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Participant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onMessageSeenByParticipants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[Participant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let history = try? JSONDecoder().decode([Participant].self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: history, contentCount: chatMessage.contentCount ?? 0))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getMessageSeenParticipants)
    }
}
