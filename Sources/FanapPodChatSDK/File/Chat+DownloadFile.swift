//
// Chat+DownloadFile.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension Chat {
    /// Downloading or getting a file from the Server / Cache.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of file and a config to download from server or use cache.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the file was successfully downloaded or not.
    ///   - cacheResponse: The cache version of file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getFile(_ request: FileRequest,
                        downloadProgress: @escaping DownloadProgressType,
                        completion: @escaping DownloadFileCompletionType,
                        cacheResponse: DownloadFileCompletionType? = nil,
                        uniqueIdResult: UniqueIdResultType? = nil)
    {
        uniqueIdResult?(request.uniqueId)
        // Check if file exist on cache or not if it doesn't exist force to download it become true.
        if cache.cacheFileManager.getFile(hashCode: request.hashCode) == nil {
            request.forceToDownloadFromServer = true
        }

        if request.forceToDownloadFromServer == true {
            let url = "\(config.fileServer)\(Routes.files.rawValue)/\(request.hashCode)"
            let headers = ["Authorization": "Bearer \(config.token)"]
            DownloadManager(callbackManager: callbacksManager).download(url: url, uniqueId: request.uniqueId, headers: headers, parameters: try? request.asDictionary(), downloadProgress: downloadProgress) { [weak self] data, response, error in
                self?.onResponse(req: request, data: data, response: response, error: error, completion: completion)
            }
        }

        if let (fileModel, path) = cache.cacheFileManager.getFile(hashCode: request.hashCode), cacheResponse != nil {
            let data = cache.cacheFileManager.getDataOfFileWith(filePath: path)
            cacheResponse?(data, fileModel, nil)
        }
    }

    func onResponse(req: FileRequest, data: Data?, response: URLResponse?, error _: Error?, completion: DownloadFileCompletionType?) {
        if let response = response as? HTTPURLResponse, (200 ... 300).contains(response.statusCode), let headers = response.allHeaderFields as? [String: Any] {
            if let data = data, let error = try? JSONDecoder().decode(ChatError.self, from: data), error.hasError == true {
                completion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.downloadError(response)))
                return
            }
            if let data = data, let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
                completion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.downloadError(response)))
                return
            }

            var name: String?
            if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last {
                name = String(fileName)
            }
            var type: String?
            if let mimetype = (headers["Content-Type"] as? String)?.split(separator: "/").last {
                type = String(mimetype)
            }
            let size = Int((headers["Content-Length"] as? String) ?? "0")
            let fileNameWithExtension = "\(name ?? "default").\(type ?? "none")"
            let fileModel = FileModel(hashCode: req.hashCode, name: fileNameWithExtension, size: size, type: type)
            if config.enableCache == true {
                cache.cacheFileManager.saveFile(fileModel, data)
            }
            completion?(data, fileModel, nil)
            let response: ChatResponse<Data?> = .init(uniqueId: req.uniqueId, result: data)
            delegate?.chatEvent(event: .file(.downloaded(response)))
        } else {
            let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]
            let message = (headers?["errorMessage"] as? String) ?? ""
            let code = (headers?["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, code: code, hasError: true, content: nil)
            completion?(nil, nil, error)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
            delegate?.chatEvent(event: .file(.downloadError(response)))
        }
    }
}
