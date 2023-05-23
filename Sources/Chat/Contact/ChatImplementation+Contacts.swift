//
// ChatImplementation+Contacts.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Contacts
import Foundation

// Request
public extension ChatImplementation {
    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getContacts, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.size, count: request.size, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
        cache?.contact?.getContacts(request.fetchRequest) { [weak self] contacts, totalCount in
            let contacts = contacts.map(\.codable)
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: contacts.count >= request.size, count: request.size, offset: request.offset, totalCount: totalCount)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: contacts, pagination: pagination))
            }
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
extension ChatImplementation {
    func onContacts(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<[Contact]> = asyncMessage.toChatResponse()
        response.contentCount = asyncMessage.chatMessage?.contentCount
        cache?.contact?.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
