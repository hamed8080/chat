//
// Chat+ThreadParticipants.swift
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
    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadParticipants(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .threadParticipants, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Participant]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.participant.getParticipantsForThread(request.threadId, request.count, request.offset) { [weak self] participants, totalCount in
            let participants = participants.map(\.codable)
            self?.responseQueue.async {
                let pagination = Pagination(hasNext: totalCount >= request.count, count: request.count, offset: request.offset)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: participants, pagination: pagination))
            }
        }
    }

    /// Get thread participants.
    ///
    /// It's the same ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadAdmins(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        getThreadParticipants(.init(request: request, admin: true), completion: completion, cacheResponse: cacheResponse, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onThreadParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        let conversation = Conversation(id: response.subjectId)
        conversation.participants = response.result
        delegate?.chatEvent(event: .thread(.threadParticipantsListChange(response)))
        cache?.participant.insert(model: conversation)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
