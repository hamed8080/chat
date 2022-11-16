//
// DownloadFileRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class DownloadFileRequestHandler {
    class func download(_ req: FileRequest,
                        _ uniqueIdResult: UniqueIdResultType? = nil,
                        _ downloadProgress: DownloadProgressType? = nil,
                        _ completion: DownloadFileCompletionType? = nil,
                        _ cacheResponse: DownloadFileCompletionType? = nil)
    {
        uniqueIdResult?(req.uniqueId)
        let chatDelegate = Chat.sharedInstance.delegate

        // Check if file exist on cache or not if it doesn't exist force to download it become true.
        if CacheFileManager.sharedInstance.getFile(hashCode: req.hashCode) == nil {
            req.forceToDownloadFromServer = true
        }

        if req.forceToDownloadFromServer == true, let token = Chat.sharedInstance.config?.token, let fileServer = Chat.sharedInstance.config?.fileServer {
            let url = "\(fileServer)\(Routes.files.rawValue)/\(req.hashCode)"
            let headers = ["Authorization": "Bearer \(token)"]
            DownloadManager.download(url: url, uniqueId: req.uniqueId, headers: headers, parameters: try? req.asDictionary(), downloadProgress: downloadProgress) { data, response, _ in
                if let response = response as? HTTPURLResponse, (200 ... 300).contains(response.statusCode), let headers = response.allHeaderFields as? [String: Any] {
                    if let data = data, let error = try? JSONDecoder().decode(ChatError.self, from: data), error.hasError == true {
                        completion?(nil, nil, error)
                        chatDelegate?.chatEvent(event: .file(.downloadError(error)))
                        return
                    }
                    if let data = data, let podspaceError = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                        let error = ChatError(message: podspaceError.message, errorCode: podspaceError.errorType?.rawValue, hasError: true)
                        completion?(nil, nil, error)
                        chatDelegate?.chatEvent(event: .file(.downloadError(error)))
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
                    if Chat.sharedInstance.config?.enableCache == true {
                        CacheFileManager.sharedInstance.saveFile(fileModel, data)
                    }
                    completion?(data, fileModel, nil)
                    chatDelegate?.chatEvent(event: .file(.downloaded(req)))
                } else {
                    let headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]
                    let message = (headers?["errorMessage"] as? String) ?? ""
                    let code = (headers?["errorCode"] as? Int) ?? 999
                    let error = ChatError(message: message, errorCode: code, hasError: true, content: nil)
                    completion?(nil, nil, error)
                    chatDelegate?.chatEvent(event: .file(.downloadError(error)))
                }
            }
        }

        if let (fileModel, path) = CacheFileManager.sharedInstance.getFile(hashCode: req.hashCode), cacheResponse != nil {
            let data = CacheFileManager.sharedInstance.getDataOfFileWith(filePath: path)
            cacheResponse?(data, fileModel, nil)
        }
    }
}
