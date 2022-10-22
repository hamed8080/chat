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
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        guard let config = chat.config else { return }
        let url = "\(config.platformHost)\(Routes.removeContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        chat.restApiRequest(req, decodeType: RemoveContactResponse.self, url: url, bodyParameter: true, method: .post, headers: headers, uniqueIdResult: uniqueIdResult) { response in
            let removeResponse = response.result as? RemoveContactResponse
            removeFromCacheIfExist(chat: chat, removeContactResponse: removeResponse, contactId: req.contactId)
            completion(removeResponse?.deteled ?? false, response.uniqueId, response.error)
        }
    }

    private class func removeFromCacheIfExist(chat _: Chat, removeContactResponse: RemoveContactResponse?, contactId: Int) {
        if removeContactResponse?.deteled == true {
            CacheFactory.write(cacheType: .deleteContacts([contactId]))
            PSM.shared.save()
        }
    }
}
