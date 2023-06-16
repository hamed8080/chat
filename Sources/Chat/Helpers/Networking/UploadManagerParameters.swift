//
// UploadManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import Foundation
import Logger

class UploadManagerParameters {
    let imageRequest: UploadImageRequest?
    let fileRequest: UploadFileRequest?
    let fileServer: String
    let token: String
    let headers: [String: String]
    var parameters: [String: Any]? { (try? imageRequest?.asDictionary()) ?? (try? fileRequest?.asDictionary()) }
    var fileName: String { imageRequest?.fileName ?? fileRequest?.fileName ?? "" }
    var mimeType: String? { imageRequest?.mimeType ?? fileRequest?.mimeType }
    var uniqueId: String { imageRequest?.uniqueId ?? fileRequest?.uniqueId ?? "" }
    var url: String {
        let userGroupHash = imageRequest?.userGroupHash ?? fileRequest?.userGroupHash
        let uploadImage = imageRequest != nil
        let userGroupPath: Routes = uploadImage ? .uploadImageWithUserGroup : .uploadFileWithUserGroup
        let normalPath: Routes = uploadImage ? .images : .files
        let path: Routes = userGroupHash != nil ? userGroupPath : normalPath
        let url = fileServer + path.rawValue.replacingOccurrences(of: "{userGroupHash}", with: userGroupHash ?? "")
        return url
    }

    init(_ imageRequest: UploadImageRequest, _ config: ChatConfig) {
        self.imageRequest = imageRequest
        fileServer = config.fileServer
        token = config.token
        headers = ["Authorization": "Bearer \(token)"]
        fileRequest = nil
    }

    init(_ fileRequest: UploadFileRequest, _ config: ChatConfig) {
        self.fileRequest = fileRequest
        fileServer = config.fileServer
        token = config.token
        headers = ["Authorization": "Bearer \(token)"]
        imageRequest = nil
    }
}
