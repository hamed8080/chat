//
// MapSearchRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class MapSearchRequestHandler {
    class func handle(_ req: MapSearchRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[MapItem]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        guard let config = chat.config, let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
        let url = "\(config.mapServer)\(Routes.mapSearch.rawValue)"
        let headers: [String: String] = ["Api-Key": mapApiKey]
        chat.restApiRequest(req,
                            decodeType: MapSearchResponse.self,
                            url: url,
                            headers: headers,
                            uniqueIdResult: uniqueIdResult,
                            completion: { response in
                                let mapSearchResponse = response.result as? MapSearchResponse
                                completion(mapSearchResponse?.items, response.uniqueId, response.error)
                            })
    }
}
