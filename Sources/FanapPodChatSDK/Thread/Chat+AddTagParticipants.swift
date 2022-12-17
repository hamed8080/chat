//
// Chat+AddTagParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    ///   - completion: The response of the request which contains list of tagParticipants added.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addTagParticipants(_ request: AddTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAddTagParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .tag(.addTagParticipant(response)))
        if let tagId = response.subjectId {
            cache.write(cacheType: .tagParticipants(response.result ?? [], tagId))
        }
        cache.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
