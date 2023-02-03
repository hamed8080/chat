//
// Chat+AddContacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public extension Chat {
    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contacts are added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addContacts(_ request: [AddContactRequest], completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType? = nil) {
        uniqueIdsResult?(request.map(\.uniqueId))
        let url = "\(config.platformHost)\(Routes.addContacts.rawValue)"
        var urlComp = URLComponents(string: url)!
        urlComp.queryItems = []
        request.forEach { contact in

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
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpMethod = HTTPMethod.post.rawValue
        logger?.log(urlReq, String(describing: type(of: [Contact].self)))
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            self?.logger?.log(data, response, error)
            let result: ChatResponse<ContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: request.first?.uniqueId, result: result?.result?.contacts, error: result?.error))
            }
            self?.cache?.contact.insert(models: result?.result?.contacts ?? [])
        }
        .resume()
    }
}
