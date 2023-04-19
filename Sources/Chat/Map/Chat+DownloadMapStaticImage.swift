//
// Chat+DownloadMapStaticImage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public extension Chat {
    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    ///   - completion: Data of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapStaticImage(_ request: MapStaticImageRequest, _ downloadProgress: DownloadProgressType? = nil, completion: @escaping CompletionType<Data?>, uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(request.uniqueId)
        request.key = config.mapApiKey
        let url = "\(config.mapServer)\(Routes.mapStaticImage.rawValue)"
        DownloadManager(callbackManager: callbacksManager).download(url: url, uniqueId: request.uniqueId, headers: nil, parameters: try? request.asDictionary(), downloadProgress: downloadProgress) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let error: ChatError? = error != nil ? ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error?.localizedDescription ?? "")", code: statusCode, hasError: error != nil) : nil
            completion(ChatResponse(uniqueId: request.uniqueId, result: data, error: error))
        }
    }
}
