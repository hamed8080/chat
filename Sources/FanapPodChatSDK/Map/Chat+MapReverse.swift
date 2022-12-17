//
// Chat+MapReverse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
public extension Chat {
    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    ///   - completion: Response of reverse address.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapReverse(_ request: MapReverseRequest, completion: @escaping CompletionType<MapReverse>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let url = "\(config.mapServer)\(Routes.mapReverse.rawValue)"
        let urlString = url.toURLCompoenentString(encodable: request) ?? url
        let headers = ["Api-Key": config.mapApiKey!]
        let bodyData = request.toData()
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            if let result: ChatResponse<MapReverse> = self?.session.decode(data, response, error) {
                self?.responseQueue.async {
                    completion(result)
                }
            }
        }
        .resume()
    }
}
