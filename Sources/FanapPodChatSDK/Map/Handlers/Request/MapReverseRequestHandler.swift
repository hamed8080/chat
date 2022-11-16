//
// MapReverseRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class MapReverseRequestHandler {
    class func handle(_ req: MapReverseRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<MapReverse>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.restApiRequest(req, decodeType: MapReverse.self, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? MapReverse, response.uniqueId, response.error)
        }
    }
}
