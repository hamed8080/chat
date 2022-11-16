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
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.restApiRequest(req, decodeType: MapRoutingResponse.self, uniqueIdResult: uniqueIdResult) { response in
            let routeResponse = response.result as? MapRoutingResponse
            completion(routeResponse?.routes, response.uniqueId, response.error)
        }
    }
}
