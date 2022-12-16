//
// Chat+AddContacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Chat {
    func requestAddContacts(_ req: [AddContactRequest], _ completion: @escaping CompletionType<[Contact]>, _ uniqueIdsResult: UniqueIdsResultType? = nil) {
        uniqueIdsResult?(req.map(\.uniqueId))
        let url = "\(config.platformHost)\(Routes.addContacts.rawValue)"
        var urlComp = URLComponents(string: url)!
        urlComp.queryItems = []
        req.forEach { contact in

            // ****
            // do not use if let to only pass un nil value if you pass un nil value in some property like email value are null so
            // the number of paramter is not equal in all contact and get invalid request like below:
            // [firstname,lastname,email,cellPhoneNumber],[firstname,lastname,cellPhoneNumber]
            // ****
            contact.typeCode = config.typeCode
            urlComp.queryItems?.append(URLQueryItem(name: "firstName", value: contact.firstName))
            urlComp.queryItems?.append(URLQueryItem(name: "lastName", value: contact.lastName))
            urlComp.queryItems?.append(URLQueryItem(name: "email", value: contact.email))
            urlComp.queryItems?.append(URLQueryItem(name: "cellphoneNumber", value: contact.cellphoneNumber))
            if let userName = contact.username {
                urlComp.queryItems?.append(URLQueryItem(name: "username", value: userName))
            }
            urlComp.queryItems?.append(URLQueryItem(name: "uniqueId", value: contact.uniqueId))
        }
        guard let urlString = urlComp.string else { return }
        var headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpMethod = HTTPMethod.post.rawValue
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.first?.uniqueId, result: result?.result?.contacts, error: result?.error))
                self?.insertContactsToCache(contacts: result?.result?.contacts)
            }
        }
        .resume()
    }
}
