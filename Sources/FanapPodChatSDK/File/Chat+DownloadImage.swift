//
// Chat+DownloadImage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Chat {
    func requestDownloadImage(_ req: ImageRequest,
                              _ uniqueIdResult: UniqueIdResultType? = nil,
                              _ downloadProgress: DownloadProgressType? = nil,
                              _ completion: DownloadImageCompletionType? = nil,
                              _ cacheResponse: DownloadImageCompletionType? = nil)
    {
        uniqueIdResult?(req.uniqueId)
        // Check if file exist on cache or not if it doesn't exist force to download it become true.
        if cacheFileManager.getImage(hashCode: req.hashCode) == nil {
            req.forceToDownloadFromServer = true
        }

        if req.forceToDownloadFromServer == true {
            let url = "\(config.fileServer)\(Routes.images.rawValue)/\(req.hashCode)"
            let headers = ["Authorization": "Bearer \(config.token)"]
            DownloadManager(callbackManager: callbacksManager).download(url: url, uniqueId: req.uniqueId, headers: headers, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { [weak self] data, response, error in
                self?.onResponseDownloadImage(req: req, data: data, response: response, error: error, completion: completion)
            }
        }

        if cacheResponse != nil {
            if req.isThumbnail, let (fileModel, path) = cacheFileManager.getThumbnail(hashCode: req.hashCode) {
                let data = cacheFileManager.getDataOfFileWith(filePath: path)
                cacheResponse?(data, fileModel, nil)
            } else if let (fileModel, path) = cacheFileManager.getImage(hashCode: req.hashCode) {
                let data = cacheFileManager.getDataOfFileWith(filePath: path)
                cacheResponse?(data, fileModel, nil)
            }
        }
    }

    func onResponseDownloadImage(req: ImageRequest, data: Data?, response: URLResponse?, error _: Error?, completion: DownloadImageCompletionType?) {
        if let response = response as? HTTPURLResponse, (200 ... 300).contains(response.statusCode), let headers = response.allHeaderFields as? [String: Any] {
            if let data = data, let error = try? JSONDecoder().decode(ChatError.self, from: data), error.hasError == true {
                completion?(nil, nil, error)
                delegate?.chatEvent(event: .file(.downloadError(error)))
                return
            }
            if let data = data, let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, errorCode: podspaceError.errorType?.rawValue, hasError: true)
                completion?(nil, nil, error)
                delegate?.chatEvent(event: .file(.downloadError(error)))
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
                cacheFileManager.saveImage(imageModel, req.isThumbnail, data)
            }
            completion?(data, imageModel, nil)
            delegate?.chatEvent(event: .file(.imageDownloaded(req)))
        } else {
            let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]
            let message = (headers?["errorMessage"] as? String) ?? ""
            let code = (headers?["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, errorCode: code, hasError: true, content: nil)
            completion?(nil, nil, error)
            delegate?.chatEvent(event: .file(.downloadError(error)))
        }
    }
}
