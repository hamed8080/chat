//
// PodspaceFileUploadResponse+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22


import Foundation
import ChatDTO
import ChatModels
import ChatCore

public extension PodspaceFileUploadResponse {
     func toMetaData(_ config: ChatConfig, width: Int? = nil, height: Int? = nil) -> FileMetaData? {
        guard let hash = result?.hash else { return nil }
        let ext = result?.extension
        let isImage = ["png", "jpg", "jpeg"].map{$0.lowercased()}.contains(ext)
         let downloadPath = config.spec.paths.podspace.download
         let path = isImage ? downloadPath.images : downloadPath.files
         let link = "\(config.spec.server.file)\(path)/\(hash)"
        let fileDetail = FileDetail(fileExtension: result?.extension,
                   link: link,
                   mimeType: result?.type,
                   name: result?.name,
                   originalName: result?.name,
                   size: result?.size,
                   fileHash: result?.hash,
                   hashCode: result?.hash,
                   parentHash: result?.parentHash,
                   actualHeight: height,
                   actualWidth: width)
        let fileMetaData = FileMetaData(file: fileDetail, fileHash: result?.hash, hashCode: result?.hash, name: result?.name)
        return fileMetaData
    }
}
