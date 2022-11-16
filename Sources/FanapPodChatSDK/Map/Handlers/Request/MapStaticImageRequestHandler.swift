//
// MapStaticImageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class MapStaticImageRequestHandler {
    class func handle(_ req: MapStaticImageRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Data>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        guard let config = chat.config else { return }
        DownloadMapStaticImageRequestHandler.handle(req: req, config: config, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Data, response.uniqueId, response.error)
        }
    }
}
