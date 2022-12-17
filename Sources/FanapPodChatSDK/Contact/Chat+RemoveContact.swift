//
// Chat+RemoveContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
extension Chat {
    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeContact(_ request: RemoveContactsRequest, completion: @escaping CompletionType<Bool>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.removeContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        request.typeCode = config.typeCode
        let bodyData = request.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<RemoveContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: request.uniqueId, result: result?.result?.deteled ?? false, error: result?.error))
                self?.removeFromCacheIfExist(removeContactResponse: result?.result, contactId: request.contactId)
            }
        }
        .resume()
    }

    func removeFromCacheIfExist(removeContactResponse: RemoveContactResponse?, contactId: Int) {
        if removeContactResponse?.deteled == true {
            cache.write(cacheType: .deleteContacts([contactId]))
            cache.save()
        }
    }
}
