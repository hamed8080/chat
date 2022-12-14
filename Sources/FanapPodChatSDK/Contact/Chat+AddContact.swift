//
// Chat+AddContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
extension Chat {
    func requestAddContact(_ req: AddContactRequest, _ completion: @escaping CompletionType<[Contact]>, _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.addContacts.rawValue)"
        var headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        req.typeCode = config.typeCode
        let bodyData = req.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.uniqueId, result: result?.result?.contacts, error: result?.error))
                self?.insertContactsToCache(contacts: result?.result?.contacts)
            }
        }
        .resume()
    }

    func insertContactsToCache(contacts: [Contact]?) {
        if config.enableCache == true, let contacts = contacts {
            CMContact.insertOrUpdate(contacts: contacts)
        }
    }
}
