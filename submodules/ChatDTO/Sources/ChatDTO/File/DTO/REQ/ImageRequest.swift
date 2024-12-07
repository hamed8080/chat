//
// ImageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ImageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let hashCode: String
    public var forceToDownloadFromServer: Bool
    public var quality: Float?
    public let size: ImageSize?
    public let crop: Bool?
    public let checkUserGroupAccess: Bool
    /// Setting this property to true leads to the thumbnail won't get stored on the disk.
    public let thumbnail: Bool
    public let withNewthumbnailAPI: Bool
    public let conversationId: Int?
    public var typeCodeIndex: Index
    public let uniqueId: String

    public init(hashCode: String, checkUserGroupAccess: Bool = true, forceToDownloadFromServer: Bool = false, quality: Float? = nil, size: ImageSize? = nil, crop: Bool? = nil, thumbnail: Bool = false, withNewthumbnailAPI: Bool = false, conversationId: Int? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.hashCode = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.size = size
        self.crop = crop
        self.quality = quality ?? 1
        self.checkUserGroupAccess = checkUserGroupAccess
        self.thumbnail = thumbnail
        self.withNewthumbnailAPI = withNewthumbnailAPI
        self.conversationId = conversationId
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = UUID().uuidString
    }

    private enum CodingKeys: String, CodingKey {
        case size
        case quality
        case crop
        case checkUserGroupAccess
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(crop, forKey: .crop)
        try? container.encodeIfPresent(quality, forKey: .quality)
        try? container.encodeIfPresent(checkUserGroupAccess, forKey: .checkUserGroupAccess)
    }
}
