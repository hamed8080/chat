//
// Chat+DownloadMapStaticImage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Chat {
    func requestDownloadMapStatic(_ req: MapStaticImageRequest, _ downloadProgress: DownloadProgressType? = nil, _ uniqueIdResult: UniqueIdResultType? = nil, _ completion: @escaping CompletionType<Data?>) {
        uniqueIdResult?(req.uniqueId)
        req.key = config.mapApiKey
        let url = "\(config.mapServer)\(Routes.mapStaticImage.rawValue)"
        DownloadManager(callbackManager: callbacksManager).download(url: url, uniqueId: req.uniqueId, headers: nil, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let error: ChatError? = error != nil ? ChatError(message: "\(ChatErrorCodes.networkError.rawValue) \(error?.localizedDescription ?? "")", errorCode: statusCode, hasError: error != nil) : nil
            completion(ChatResponse(uniqueId: req.uniqueId, result: data, error: error))
        }
    }
}
