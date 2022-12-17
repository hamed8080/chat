//
// PodspaceFileUploadResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public struct PodspaceFileUploadResponse: Decodable {
    public let status: Int
    public let path: String?
    public let error: String?
    /// For when a error rise and detail more
    public let message: String?
    public let result: UploadFileResponse?
    public let timestamp: String?
    public let reference: String?

    var errorType: FileUploadError? {
        FileUploadError(rawValue: status)
    }
}

enum FileUploadError: Int {
    case noContent = 204
    case fileNotSent = 400
    case unauthorized = 401
    case insufficientSpace = 402
    case forbidden = 403
    case notFound = 404
}
