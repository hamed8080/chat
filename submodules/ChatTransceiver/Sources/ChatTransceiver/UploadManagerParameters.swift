//
// UploadManager.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public struct UploadManagerParameters: Sendable {
    public let imageRequest: UploadImageRequest?
    public let fileRequest: UploadFileRequest?
    public var data: Data? { imageRequest?.data ?? fileRequest?.data }
    public let token: String
    public var headers: [String: String]
    public var parameters: [String: Any]? { (try? imageRequest?.asDictionary()) ?? (try? fileRequest?.asDictionary()) }
    public var fileName: String { imageRequest?.fileName ?? fileRequest?.fileName ?? "" }
    public var mimeType: String? { imageRequest?.mimeType ?? fileRequest?.mimeType }
    public var uniqueId: String { imageRequest?.uniqueId ?? fileRequest?.uniqueId ?? "" }
    public let url: String

    public init(url: String, _ imageRequest: UploadImageRequest, headers: [String: String] = [:], token: String) {
        self.url = url
        self.imageRequest = imageRequest
        self.token = token
        self.headers = headers
        self.headers["Authorization"] = "Bearer \(token)"
        fileRequest = nil
    }

    public init(url: String, _ fileRequest: UploadFileRequest, headers: [String: String] = [:], token: String) {
        self.url = url
        self.fileRequest = fileRequest
        self.token = token
        self.headers = headers
        self.headers["Authorization"] = "Bearer \(token)"
        imageRequest = nil
    }
}
