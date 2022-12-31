//
// Chat+Contacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Contacts
import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(count: request.size, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.get(cacheType: .getCashedContacts(request)) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(count: request.size, offset: request.offset, totalCount: CMContact.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func searchContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        getContacts(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onContacts(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<[Contact]> = asyncMessage.toChatResponse()
        response.contentCount = asyncMessage.chatMessage?.contentCount
        cache?.write(cacheType: .casheContacts(response.result ?? []))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
