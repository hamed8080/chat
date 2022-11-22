//
// RemoveContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class RemoveContactRequestHandler {
    class func handle(_ req: RemoveContactsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Bool>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.restApiRequest(req, decodeType: RemoveContactResponse.self, uniqueIdResult: uniqueIdResult) { response in
            let removeResponse = response.result as? RemoveContactResponse
            removeFromCacheIfExist(chat: chat, removeContactResponse: removeResponse, contactId: req.contactId)
            completion(removeResponse?.deteled ?? false, response.uniqueId, response.error)
        }
    }

    private class func removeFromCacheIfExist(chat _: Chat, removeContactResponse: RemoveContactResponse?, contactId: Int) {
        if removeContactResponse?.deteled == true {
            CacheFactory.write(cacheType: .deleteContacts([contactId]))
            CacheFactory.save()
        }
    }
}
