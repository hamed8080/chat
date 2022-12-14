//
// Chat+MapSearch.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request - Response
extension Chat {
    func requestMapSearch(_ req: MapSearchRequest, _ completion: @escaping CompletionType<[MapItem]>, _: UniqueIdResultType? = nil) {
        let url = "\(config.mapServer)\(Routes.mapSearch.rawValue)"
        let urlString = url.toURLCompoenentString(encodable: req) ?? url
        let headers = ["Api-Key": config.mapApiKey!]
        let bodyData = req.toData()
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        session.dataTask(with: urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapSearchResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: req.uniqueId, result: result?.result?.items, error: result?.error))
            }
        }
        .resume()
    }
}
