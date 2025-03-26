//
// PodspaceFileUploadResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct PodspaceFileUploadResponse: Decodable, Sendable {
    public let status: Int
    public let path: String?
    public let error: String?
    /// For when a error rise and detail more
    public let message: String?
    public let result: UploadFileResponse?
    public let timestamp: String?
    public let reference: String?

    public var errorType: FileUploadError? {
        FileUploadError(rawValue: status)
    }

    private enum CodingKeys: CodingKey {
        case status
        case path
        case error
        case message
        case result
        case timestamp
        case reference
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Int.self, forKey: .status)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.result = try container.decodeIfPresent(UploadFileResponse.self, forKey: .result)
        self.timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
        self.reference = try container.decodeIfPresent(String.self, forKey: .reference)
    }

    public init(status: Int, path: String? = nil, error: String? = nil, message: String? = nil, result: UploadFileResponse? = nil, timestamp: String? = nil, reference: String? = nil) {
        self.status = status
        self.path = path
        self.error = error
        self.message = message
        self.result = result
        self.timestamp = timestamp
        self.reference = reference
    }
}

public enum FileUploadError: Int, Sendable {
    case noContent = 204
    case fileNotSent = 400
    case unauthorized = 401
    case insufficientSpace = 402
    case forbidden = 403
    case notFound = 404
}
