//
// Chat+ThreadParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestThreadParticipants(_ req: ThreadParticipantsRequest,
                                   _ completion: @escaping CompletionType<[Participant]>,
                                   _ cacheResponse: CacheResponseType<[Participant]>?,
                                   _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Participant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getThreadParticipants(req)) { (response: ChatResponse<[Participant]>) in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMParticipant.crud.getTotalCount(predicate: predicate))
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onThreadParticipants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadParticipantsListChange(threadId: chatMessage.subjectId, participants)))
        cache.write(cacheType: .participants(participants, chatMessage.subjectId))
        cache.save()
        guard let callback: CompletionType<[Participant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: participants, contentCount: chatMessage.contentCount ?? 0))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .threadParticipants)
    }
}
