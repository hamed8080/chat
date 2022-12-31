//
// Chat+ArchiveThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of archived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func archiveThread(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .archiveThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of unarchived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unarchiveThread(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .unarchiveThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onArchiveUnArchiveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        cache?.write(cacheType: .archiveUnarchiveAhread(asyncMessage.chatMessage?.type == .archiveThread, response.subjectId ?? 0))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
