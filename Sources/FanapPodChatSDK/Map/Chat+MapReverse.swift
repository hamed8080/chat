//
// Chat+MapReverse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
extension Chat {
    func requestMapReverse(_ req: MapReverseRequest, _ completion: @escaping CompletionType<MapReverse>, _: UniqueIdResultType? = nil) {
        let url = "\(config.mapServer)\(Routes.mapReverse.rawValue)"
        let urlString = url.toURLCompoenentString(encodable: req) ?? url
        let headers = ["Api-Key": config.mapApiKey!]
        let bodyData = req.toData()
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
