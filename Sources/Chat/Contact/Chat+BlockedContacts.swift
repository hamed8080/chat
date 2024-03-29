//
// Chat+BlockedContacts.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Contacts
import Foundation

// Request
public extension Chat {
    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer is the list of blocked contacts.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getBlockedContacts(_ request: BlockedListRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getBlocked, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onBlockedContacts(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Contact]> = asyncMessage.toChatResponse()
        cache?.contact.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
