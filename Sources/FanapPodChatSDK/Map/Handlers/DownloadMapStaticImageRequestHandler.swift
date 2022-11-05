//
// DownloadMapStaticImageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class DownloadMapStaticImageRequestHandler {
    class func handle(req: MapStaticImageRequest,
                      config: ChatConfig,
                      downloadProgress: DownloadProgressType? = nil,
                      uniqueIdResult: UniqueIdResultType = nil,
                      completion: @escaping (ChatResponse) -> Void)
    {
        uniqueIdResult?(req.uniqueId)
        guard let mapApiKey = config.mapApiKey else {
            Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "❌ map api key was null set it through config!")
            return
        }
        req.key = mapApiKey
        let url = "\(config.mapServer)\(Routes.mapStaticImage.rawValue)"
        DownloadManager.download(url: url, uniqueId: req.uniqueId, headers: nil, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, _, _ in
            if let data = data {
                let response = ChatResponse(result: data)
                completion(response)
            }
        }
    }
}
