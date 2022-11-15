//
// AddContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class AddContactRequestHandler {
    class func handle(_ req: AddContactRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.restApiRequest(req, decodeType: ContactResponse.self, uniqueIdResult: uniqueIdResult) { response in
            let contactResponse = response.result as? ContactResponse
            addToCacheIfEnabled(chat: chat, contactsResponse: contactResponse)
            completion(contactResponse?.contacts, response.uniqueId, response.error)
        }
    }

    class func addToCacheIfEnabled(chat: Chat, contactsResponse: ContactResponse?) {
        if chat.config?.enableCache == true, let contacts = contactsResponse?.contacts {
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}
