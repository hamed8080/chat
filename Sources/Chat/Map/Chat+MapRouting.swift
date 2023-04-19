//
// Chat+MapRouting.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request - Response
public extension Chat {
    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapRouting(_ request: MapRoutingRequest, completion: @escaping CompletionType<[Route]>, uniqueIdResult _: UniqueIdResultType? = nil) {
        let urlString = "\(config.mapServer)\(Routes.mapRouting.rawValue)"
        var url = URL(string: urlString)!
        url.appendQueryItems(with: request)
        let headers = ["Api-Key": config.mapApiKey!]
        let bodyData = request.data
        var urlReq = URLRequest(url: url)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<MapRoutingResponse>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                completion(ChatResponse(uniqueId: request.uniqueId, result: result?.result?.routes, error: result?.error))
            }
        }
        .resume()
    }
}
