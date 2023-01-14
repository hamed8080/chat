//
// Chat+UpdateContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Contacts
import Foundation

// Request
public extension Chat {
    /// Update a particular contact.
    ///
    /// Update name or other details of a contact.
    /// - Parameters:
    ///   - req: The request of what you need to be updated.
    ///   - completion: The list of updated contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func updateContact(_ request: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.updateContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        request.typeCode = config.typeCode
        let bodyData = request.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        logger?.log(urlReq, String(describing: type(of: [Contact].self)))
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            self?.logger?.log(data, response, error)
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: request.uniqueId, result: result?.result?.contacts, error: result?.error))
            }
            self?.cache?.contact?.insert(models: result?.result?.contacts ?? [])
        }
        .resume()
    }
}
