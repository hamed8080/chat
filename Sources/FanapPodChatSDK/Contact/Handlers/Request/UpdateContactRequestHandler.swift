//
// UpdateContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation

class UpdateContactRequestHandler {
    class func handle(_ req: UpdateContactRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Contact]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        guard let config = chat.config else { return }
        let url = "\(config.platformHost)\(Routes.updateContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        chat.restApiRequest(req, decodeType: ContactResponse.self, url: url, bodyParameter: true, method: .post, headers: headers, uniqueIdResult: uniqueIdResult) { response in
            let contactResponse = response.result as? ContactResponse
            insertOrUpdateCache(chat: chat, contactsResponse: contactResponse)
            completion(contactResponse?.contacts, response.uniqueId, response.error)
        }
    }

    private class func insertOrUpdateCache(chat _: Chat, contactsResponse: ContactResponse?) {
        if let contacts = contactsResponse?.contacts {
            CMContact.insertOrUpdate(contacts: contacts)
        }
        PSM.shared.save()
    }
}
