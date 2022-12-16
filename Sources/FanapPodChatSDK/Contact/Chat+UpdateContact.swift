//
// Chat+UpdateContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation

// Request
extension Chat {
    func requestUpdateContact(_ req: UpdateContactRequest, _ completion: @escaping CompletionType<[Contact]>, _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.updateContacts.rawValue)"
        var headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        req.typeCode = config.typeCode
        let bodyData = req.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        logger?.restRequest(urlReq, String(describing: type(of: [Contact].self)))
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.uniqueId, result: result?.result?.contacts, error: result?.error))
                self?.insertOrUpdateCache(contactsResponse: result?.result)
            }
        }
        .resume()
    }

    func insertOrUpdateCache(contactsResponse: ContactResponse?) {
        if let contacts = contactsResponse?.contacts {
            CMContact.insertOrUpdate(contacts: contacts)
        }
        cache.save()
    }
}
