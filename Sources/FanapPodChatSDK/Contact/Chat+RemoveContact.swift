//
// Chat+RemoveContact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
extension Chat {
    func requestRemoveContact(_ req: RemoveContactsRequest, _ completion: @escaping CompletionType<Bool>, _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.removeContacts.rawValue)"
        var headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        req.typeCode = config.typeCode
        let bodyData = req.getParameterData()
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.httpMethod = HTTPMethod.post.rawValue
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<RemoveContactResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.uniqueId, result: result?.result?.deteled ?? false, error: result?.error))
                self?.removeFromCacheIfExist(removeContactResponse: result?.result, contactId: req.contactId)
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
