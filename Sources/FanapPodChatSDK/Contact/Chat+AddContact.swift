//
// Chat+AddContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
extension Chat {
    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contact is added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addContact(_ request: AddContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.addContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        request.typeCode = config.typeCode
        let bodyData = request.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: request.uniqueId, result: result?.result?.contacts, error: result?.error))
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