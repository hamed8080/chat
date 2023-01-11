//
// Chat+DownloadImage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension Chat {
    /// Downloading or getting an image from the Server / cache?.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache?.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the image was successfully downloaded or not. The URL of the image cached is nil if you set ``ChatConfig/enableCache`` to false.
    ///   - cacheResponse: The path of the image. The data is nill because it is up to client to how to read data from disk.
    ///    As an example there are times you want to read part of an image  in a stream format so it would be overhead for system to read whole unuesd data.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getImage(_ request: ImageRequest,
                         downloadProgress: @escaping DownloadProgressType,
                         completion: @escaping DownloadImageCompletionType,
                         cacheResponse: DownloadImageCompletionType? = nil,
                         uniqueIdResult: UniqueIdResultType? = nil)
    {
        uniqueIdResult?(request.uniqueId)
        let url = "\(config.fileServer)\(Routes.images.rawValue)/\(request.hashCode)"
        // Check if file exist on cache or not if it doesn't exist force to download it become true.
        if cacheFileManager?.isFileExist(url: URL(string: url)!) == false {
            request.forceToDownloadFromServer = true
        }

        if request.forceToDownloadFromServer == true {
            let headers = ["Authorization": "Bearer \(config.token)"]
            DownloadManager(callbackManager: callbacksManager)
                .download(url: url,
                          uniqueId: request.uniqueId,
                          headers: headers,
                          parameters: try? request.asDictionary(),
                          downloadProgress: downloadProgress) { [weak self] data, response, error in
                    self?.onResponseDownloadImage(req: request, url: url, data: data, response: response, error: error, completion: completion)
                }
        }

        if config.enableCache, let filePath = cacheFileManager?.filePath(url: URL(string: url)!), cacheResponse != nil {
            let image = CacheImageManager(pm: persistentManager, logger: logger).first(with: request.hashCode)
            cacheResponse?(nil, filePath, image?.codable, nil)
        }
    }

    func onResponseDownloadImage(req: ImageRequest, url: String, data: Data?, response: URLResponse?, error _: Error?, completion: DownloadImageCompletionType?) {
        if let response = response as? HTTPURLResponse, (200 ... 300).contains(response.statusCode), let headers = response.allHeaderFields as? [String: Any] {
            if let data = data, let error = try? JSONDecoder().decode(ChatError.self, from: data), error.hasError == true {
                completion?(nil, nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.downloadError(response)))
                return
            }
            if let data = data, let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
                completion?(nil, nil, nil, error)
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
            let image = Image(size: size, name: fileNameWithExtension, hashCode: req.hashCode)
            CacheImageManager(pm: persistentManager, logger: logger).insert(models: [image])
            let filePath = cacheFileManager?.saveFile(url: URL(string: url)!, data: data ?? Data())
            completion?(data, filePath, image, nil)
            let response: ChatResponse<Data?> = .init(uniqueId: req.uniqueId, result: data)
            delegate?.chatEvent(event: .file(.imageDownloaded(response)))
        } else {
            let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]
            let message = (headers?["errorMessage"] as? String) ?? ""
            let code = (headers?["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, code: code, hasError: true, content: nil)
            completion?(nil, nil, nil, error)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
            delegate?.chatEvent(event: .file(.downloadError(response)))
        }
    }
}
