//
// DownloadManagerParameters.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Foundation

public struct DownloadManagerParameters: CustomDebugStringConvertible, Sendable {
    public var forceToDownload: Bool = false
    public let url: URL
    public let token: String
    public var headers: [String: String]
    public var params: [String: Sendable]?
    public let isImage: Bool
    public let thumbnail: Bool
    public var hashCode: String?
    public var method: HTTPMethod = .get
    public var conversationId: Int?
    public var typeCodeIndex: Int
    public var uniqueId: String

    public init(forceToDownload: Bool = false,
                url: URL,
                token: String,
                params: [String: Sendable]? = nil,
                headers: [String: String] = [:],
                thumbnail: Bool = false,
                hashCode: String? = nil,
                isImage: Bool = false,
                method: HTTPMethod = .get,
                conversationId: Int? = nil,
                typeCodeIndex: Int = 0,
                uniqueId: String) {
        self.forceToDownload = forceToDownload
        self.url = url
        self.token = token
        self.params = params
        self.isImage = isImage
        self.hashCode = hashCode
        self.method = method
        self.uniqueId = uniqueId
        self.thumbnail = thumbnail
        self.headers = headers
        self.conversationId = conversationId
        self.typeCodeIndex = typeCodeIndex
        self.headers["Authorization"] = "Bearer \(token)"
    }

    public var debugDescription: String {
        """
        forceToDownload: \(forceToDownload),
        url: \(url.absoluteString),
        token: \(token),
        headers: \(headers),
        params: \(String(describing: params)),
        isImage: \(isImage),
        thumbnail: \(thumbnail),
        hashCode: \(String(describing: hashCode)),
        method: \(method),
        conversationId: \(String(describing: conversationId)),
        typeCodeIndex: \(typeCodeIndex),
        uniqueId: \(uniqueId),
        """
    }

}
