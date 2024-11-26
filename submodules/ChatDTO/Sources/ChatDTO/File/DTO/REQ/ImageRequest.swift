//
// ImageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ImageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    // API variables
    public let hashCode: String
    public var quality: Float?
    public let size: ImageSize?
    public let width: Int?
    public let height: Int?
    public let keepRatio: Bool?
    public let froceConvert: Bool?
    public let crop: Bool?
    public let cropX: Int?
    public let cropY: Int?
    public let cropWidth: Int?
    public let cropHeight: Int?
    public let password: String?

    // Miscellaneous variables, there is a chance all these variable removed in the future.
    public var forceToDownloadFromServer: Bool
    public let checkUserGroupAccess: Bool
    /// Setting this property to true leads to the thumbnail won't get stored on the disk.
    public let thumbnail: Bool
    public let withNewthumbnailAPI: Bool
    public let conversationId: Int?
    public var typeCodeIndex: Index
    public let uniqueId: String

    public init(
        hashCode: String,
        checkUserGroupAccess: Bool = true,
        forceToDownloadFromServer: Bool = false,
        quality: Float? = nil,
        size: ImageSize? = nil,
        crop: Bool? = nil,
        thumbnail: Bool = false,
        width: Int? = nil,
        height: Int? = nil,
        keepRatio: Bool? = nil,
        froceConvert: Bool? = nil,
        cropX: Int? = nil,
        cropY: Int? = nil,
        cropWidth: Int? = nil,
        cropHeight: Int? = nil,
        password: String? = nil,        
        withNewthumbnailAPI: Bool = false,
        conversationId: Int? = nil,
        typeCodeIndex: TypeCodeIndexProtocol.Index = 0
    ) {
        self.hashCode = hashCode
        self.size = size
        self.crop = crop
        self.quality = quality ?? 1
        self.quality = quality
        self.width = width
        self.height = height
        self.keepRatio = keepRatio
        self.froceConvert = froceConvert
        self.cropX = cropX
        self.cropY = cropY
        self.cropWidth = cropWidth
        self.cropHeight = cropHeight
        self.password = password
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.checkUserGroupAccess = checkUserGroupAccess
        self.thumbnail = thumbnail
        self.withNewthumbnailAPI = withNewthumbnailAPI
        self.conversationId = conversationId
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = UUID().uuidString
    }

    private enum CodingKeys: String, CodingKey {
        case size
        case crop
        case quality
        case hashCode
        case width
        case height
        case keepRatio
        case froceConvert
        case cropX
        case cropY
        case cropWidth
        case cropHeight
        case password
        case checkUserGroupAccess
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(quality, forKey: .quality)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(crop, forKey: .crop)
        try? container.encodeIfPresent(width, forKey: .width)
        try? container.encodeIfPresent(height, forKey: .height)
        try? container.encodeIfPresent(keepRatio, forKey: .keepRatio)
        try? container.encodeIfPresent(froceConvert, forKey: .froceConvert)
        try? container.encodeIfPresent(cropX, forKey: .cropX)
        try? container.encodeIfPresent(cropY, forKey: .cropY)
        try? container.encodeIfPresent(cropWidth, forKey: .cropWidth)
        try? container.encodeIfPresent(cropHeight, forKey: .cropHeight)
        try? container.encodeIfPresent(password, forKey: .password)
        try? container.encodeIfPresent(checkUserGroupAccess, forKey: .checkUserGroupAccess)
    }
}
