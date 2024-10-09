//
// UploadManager.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public struct UploadManagerParameters {
    public let imageRequest: UploadImageRequest?
    public let fileRequest: UploadFileRequest?
    public var data: Data? { imageRequest?.data ?? fileRequest?.data }
    public let fileServer: String
    public let token: String
    public var headers: [String: String]
    public var parameters: [String: Any]? { (try? imageRequest?.asDictionary()) ?? (try? fileRequest?.asDictionary()) }
    public var fileName: String { imageRequest?.fileName ?? fileRequest?.fileName ?? "" }
    public var mimeType: String? { imageRequest?.mimeType ?? fileRequest?.mimeType }
    public var uniqueId: String { imageRequest?.uniqueId ?? fileRequest?.uniqueId ?? "" }
    var url: String {
        let userGroupHash = imageRequest?.userGroupHash ?? fileRequest?.userGroupHash
        let uploadImage = imageRequest != nil
        let userGroupPath: Routes = uploadImage ? .uploadImageWithUserGroup : .uploadFileWithUserGroup
        let normalPath: Routes = uploadImage ? .images : .files
        let path: Routes = userGroupHash != nil ? userGroupPath : normalPath
        let url = fileServer + path.rawValue.replacingOccurrences(of: "{userGroupHash}", with: userGroupHash ?? "")
        return url
    }

    public init(_ imageRequest: UploadImageRequest, headers: [String: String] = [:], token: String, fileServer: String) {
        self.imageRequest = imageRequest
        self.fileServer = fileServer
        self.token = token
        self.headers = headers
        self.headers["Authorization"] = "Bearer \(token)"
        fileRequest = nil
    }

    public init(_ fileRequest: UploadFileRequest, headers: [String: String] = [:], token: String, fileServer: String) {
        self.fileRequest = fileRequest
        self.fileServer = fileServer
        self.token = token
        self.headers = headers
        self.headers["Authorization"] = "Bearer \(token)"
        imageRequest = nil
    }
}
