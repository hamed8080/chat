//
// ChatImplementation+RemoveContact.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeContact(_ request: RemoveContactsRequest, completion: @escaping CompletionType<Bool>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let url = "\(config.platformHost)\(Routes.removeContacts.rawValue)"
        let headers: [String: String] = ["_token_": config.token, "_token_issuer_": "1"]
        let bodyData = request.parameterData
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.method = .post
        logger.logHTTPRequest(urlReq, String(describing: type(of: Bool.self)), persist: true, type: .sent)
        session.dataTask(urlReq) { [weak self] data, response, error in
            self?.logger.logHTTPResponse(data, response, error, persist: true, type: .received, userInfo: self?.loggerUserInfo)
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
            cache?.contact?.delete(contactId)
        }
    }
}
