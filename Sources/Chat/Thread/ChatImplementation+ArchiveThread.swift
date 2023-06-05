//
// ChatImplementation+ArchiveThread.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of archived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func archiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .archiveThread, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of unarchived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unarchiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .unarchiveThread, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onArchiveUnArchiveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        cache?.conversation?.archive(asyncMessage.chatMessage?.type == .archiveThread, response.subjectId ?? -1)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
