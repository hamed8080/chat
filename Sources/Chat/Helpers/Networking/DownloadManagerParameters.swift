//
// DownloadManagerParameters.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import ChatCore
import ChatDTO
import Foundation
import Logger

struct DownloadManagerParameters {
    var forceToDownload: Bool = false
    let url: URL
    let token: String
    var headers: [String: String]? { ["Authorization": "Bearer \(token)"] }
    var params: [String: Any]?
    let isImage: Bool
    let thumbnail: Bool
    var hashCode: String?
    var method: HTTPMethod = .get
    var uniqueId: String

    init(forceToDownload: Bool = false, url: URL, token: String, params: [String: Any]? = nil, thumbnail: Bool = false, isImage: Bool = false, method: HTTPMethod = .get, uniqueId: String) {
        self.forceToDownload = forceToDownload
        self.url = url
        self.token = token
        self.params = params
        self.isImage = isImage
        hashCode = nil
        self.method = method
        self.uniqueId = uniqueId
        self.thumbnail = thumbnail
    }

    init(_ request: ImageRequest, _ config: ChatConfig, _ cache: CacheFileManagerProtocol?) {
        isImage = true
        hashCode = request.hashCode
        thumbnail = request.thumbnail
        url = URL(string: "\(config.fileServer)\(Routes.images.rawValue)/\(request.hashCode)")!
        params = try? request.asDictionary()
        token = config.token
        forceToDownload = request.forceToDownloadFromServer || cache?.isFileExist(url: url) == false
        uniqueId = request.uniqueId
    }

    init(_ request: FileRequest, _ config: ChatConfig, _ cache: CacheFileManagerProtocol?) {
        isImage = false
        hashCode = request.hashCode
        thumbnail = false
        url = URL(string: "\(config.fileServer)\(Routes.files.rawValue)/\(request.hashCode)")!
        params = try? request.asDictionary()
        token = config.token
        forceToDownload = request.forceToDownloadFromServer || cache?.isFileExist(url: url) == false
        uniqueId = request.uniqueId
    }
}
