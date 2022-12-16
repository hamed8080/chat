//
// Chat+MapRouting.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request - Response
extension Chat {
    func requestMapRouting(_ req: MapRoutingRequest, _ completion: @escaping CompletionType<[Route]>, _: UniqueIdResultType? = nil) {
        let url = "\(config.mapServer)\(Routes.mapRouting.rawValue)"
        let urlString = url.toURLCompoenentString(encodable: req) ?? url
        let headers = ["Api-Key": config.mapApiKey!]
        let bodyData = req.toData()
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapRoutingResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.uniqueId, result: result?.result?.routes, error: result?.error))
            }
        }
        .resume()
    }
}
