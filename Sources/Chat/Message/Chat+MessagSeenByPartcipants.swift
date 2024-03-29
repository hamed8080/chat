//
// Chat+MessagSeenByPartcipants.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Retrieve the list of participants to who have seen the message.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func messageSeenByUsers(_ request: MessageSeenByUsersRequest, completion: @escaping CacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getMessageSeenParticipants, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Participant]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onMessageSeenByParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
