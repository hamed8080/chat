//
// DownloadManagerParameters+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatTransceiver
import ChatDTO
import ChatCore

public extension DownloadManagerParameters {

    init(_ request: ImageRequest, _ config: ChatConfig, _ cache: CacheFileManagerProtocol?) {
        var request = request
        let url: URL
        if request.thumbnail, request.withNewthumbnailAPI {
            url = URL(string: "\(config.fileServer)\(Routes.thumbnail.rawValue.replacingOccurrences(of: "{hashCode}", with: request.hashCode))")!
            request.quality = 1
        } else {
            url = URL(string: "\(config.fileServer)\(Routes.images.rawValue)/\(request.hashCode)")!
        }
        self.init(forceToDownload: request.forceToDownloadFromServer || cache?.isFileExist(url: url) == false,
                  url: url,
                  token: config.token,
                  params: (try? request.asSendableDictionary()),
                  thumbnail: request.thumbnail,
                  hashCode: request.hashCode,
                  isImage: true,
                  conversationId: request.conversationId,
                  typeCodeIndex: request.typeCodeIndex,
                  uniqueId: request.uniqueId)
    }

    init(_ request: FileRequest, _ config: ChatConfig, _ cache: CacheFileManagerProtocol?) {
        let url = URL(string: "\(config.fileServer)\(Routes.files.rawValue)/\(request.hashCode)")!
        self.init(forceToDownload: request.forceToDownloadFromServer || cache?.isFileExist(url: url) == false,
                  url: url,
                  token: config.token,
                  params: try? request.asSendableDictionary(),
                  thumbnail: false,
                  hashCode: request.hashCode,
                  isImage: false,
                  conversationId: request.conversationId,
                  typeCodeIndex: request.typeCodeIndex,
                  uniqueId: request.uniqueId)
    }
}
