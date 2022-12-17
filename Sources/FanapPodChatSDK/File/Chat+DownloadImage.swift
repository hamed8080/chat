//
// Chat+DownloadImage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension Chat {
    /// Downloading or getting an image from the Server / Cache.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the image was successfully downloaded or not.
    ///   - cacheResponse: The cache version of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getImage(_ request: ImageRequest,
                         downloadProgress: @escaping DownloadProgressType,
                         completion: @escaping DownloadImageCompletionType,
                         cacheResponse: DownloadImageCompletionType? = nil,
                         uniqueIdResult: UniqueIdResultType? = nil)
    {
        uniqueIdResult?(request.uniqueId)
        // Check if file exist on cache or not if it doesn't exist force to download it become true.
        if cache.cacheFileManager.getImage(hashCode: request.hashCode) == nil {
            request.forceToDownloadFromServer = true
        }

        if request.forceToDownloadFromServer == true {
            let url = "\(config.fileServer)\(Routes.images.rawValue)/\(request.hashCode)"
            let headers = ["Authorization": "Bearer \(config.token)"]
            DownloadManager(callbackManager: callbacksManager).download(url: url, uniqueId: request.uniqueId, headers: headers, parameters: try? request.asDictionary(), downloadProgress: downloadProgress) { [weak self] data, response, error in
                self?.onResponseDownloadImage(req: request, data: data, response: response, error: error, completion: completion)
            }
        }

        if cacheResponse != nil {
            if request.isThumbnail, let (fileModel, path) = cache.cacheFileManager.getThumbnail(hashCode: request.hashCode) {
                let data = cache.cacheFileManager.getDataOfFileWith(filePath: path)
                cacheResponse?(data, fileModel, nil)
            } else if let (fileModel, path) = cache.cacheFileManager.getImage(hashCode: request.hashCode) {
                let data = cache.cacheFileManager.getDataOfFileWith(filePath: path)
                cacheResponse?(data, fileModel, nil)
            }
        }
    }

    func onResponseDownloadImage(req: ImageRequest, data: Data?, response: URLResponse?, error _: Error?, completion: DownloadImageCompletionType?) {
        if let response = response as? HTTPURLResponse, (200 ... 300).contains(response.statusCode), let headers = response.allHeaderFields as? [String: Any] {
            if let data = data, let error = try? JSONDecoder().decode(ChatError.self, from: data), error.hasError == true {
                completion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.downloadError(response)))
                return
            }
            if let data = data, let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, errorCode: podspaceError.errorType?.rawValue, hasError: true)
                completion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.downloadError(response)))
                return
            }

            var name: String?
            if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last {
                name = String(fileName)
            }

            let size = Int((headers["Content-Length"] as? String) ?? "0")
            let fileNameWithExtension = "\(name ?? "default")"
            var imageModel = ImageModel(hashCode: req.hashCode, name: fileNameWithExtension, size: size)
            if config.enableCache == true {
                imageModel.hashCode = req.isThumbnail ? (req.hashCode + "-Thumbnail") : req.hashCode
                cache.cacheFileManager.saveImage(imageModel, req.isThumbnail, data)
            }
            completion?(data, imageModel, nil)
            let response: ChatResponse<Data?> = .init(uniqueId: req.uniqueId, result: data)
            delegate?.chatEvent(event: .file(.imageDownloaded(response)))
        } else {
            let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]
            let message = (headers?["errorMessage"] as? String) ?? ""
            let code = (headers?["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, errorCode: code, hasError: true, content: nil)
            completion?(nil, nil, error)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
            delegate?.chatEvent(event: .file(.downloadError(response)))
        }
    }
}
