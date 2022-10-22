//
// MapRoutingRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class MapRoutingRequestHandler {
    class func handle(_ req: MapRoutingRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Route]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        guard let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
        let url = "\(config.mapServer)\(Routes.mapRouting.rawValue)"
        let headers: [String: String] = ["Api-Key": mapApiKey]
        chat.restApiRequest(req,
                            decodeType: MapRoutingResponse.self,
                            url: url,
                            headers: headers,
                            uniqueIdResult: uniqueIdResult) { response in
            let routeResponse = response.result as? MapRoutingResponse
            completion(routeResponse?.routes, response.uniqueId, response.error)
        }
    }
}
