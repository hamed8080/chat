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
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.restApiRequest(req, decodeType: MapSearchResponse.self, uniqueIdResult: uniqueIdResult) { response in
            let mapSearchResponse = response.result as? MapSearchResponse
            completion(mapSearchResponse?.items, response.uniqueId, response.error)
        }
    }
}
