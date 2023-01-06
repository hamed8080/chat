//
// Chat+ThreadParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
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
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Participant]>) in
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.get(cacheType: .getThreadParticipants(request)) { (response: ChatResponse<[Participant]>) in
            let predicate = NSPredicate(format: "threadId == %i", request.threadId)
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: CMParticipant.crud.getTotalCount(predicate: predicate))
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
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
        request.admin = true
        getThreadParticipants(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onThreadParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .thread(.threadParticipantsListChange(response)))
        cache?.write(cacheType: .participants(response.result ?? [], response.subjectId ?? 0))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
