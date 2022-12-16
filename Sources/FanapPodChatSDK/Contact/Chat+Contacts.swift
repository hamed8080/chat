//
// Chat+Contacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestContacts(_ req: ContactsRequest,
                         _ completion: @escaping CompletionType<[Contact]>,
                         _ cacheResponse: CacheResponseType<[Contact]>? = nil,
                         _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(count: req.size, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getCashedContacts(req)) { (response: ChatResponse<[Contact]>) in
            let pagination = PaginationWithContentCount(count: req.size, offset: req.offset, totalCount: CMContact.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onContacts(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let contacts = try? JSONDecoder().decode([Contact].self, from: data) else { return }
        cache.write(cacheType: .casheContacts(contacts))
        cache.save()
        guard let callback: CompletionType<[Contact]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: contacts, contentCount: chatMessage.contentCount ?? contacts.count))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getContacts)
    }
}
