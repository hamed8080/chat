//
// Chat+AddParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addParticipant(_ request: AddParticipantRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAddParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        CacheParticipantManager(pm: persistentManager, logger: logger).insert(models: response.result?.participants ?? [])
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        delegate?.chatEvent(event: .thread(.threadAddParticipants(.init(uniqueId: response.uniqueId, result: response.result?.participants, time: response.time))))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
