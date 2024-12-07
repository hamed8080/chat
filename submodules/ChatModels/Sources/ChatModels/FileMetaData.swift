//
// FileMetaData.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct FileMetaData: Codable, Hashable, Sendable {
    public let file: FileDetail?
    public let fileHash: String?
    public let hashCode: String?
    public let name: String?
    public var latitude: Double?
    public var longitude: Double?
    public var reverse: String?
    public var mapLink: String?

    public init(file: FileDetail,
                fileHash: String? = nil,
                hashCode: String? = nil,
                name: String? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                reverse: String? = nil,
                mapLink: String? = nil
    )
    {
        self.file = file
        self.fileHash = fileHash
        self.name = name
        self.hashCode = hashCode
        self.longitude = longitude
        self.latitude = latitude
        self.reverse = reverse
        self.mapLink = mapLink
    }
}

public struct FileDetail: Codable, Hashable, Sendable {
    public let actualHeight: Int?
    public let actualWidth: Int?
    public let `extension`: String?
    public let link: String?
    public let mimeType: String?
    public let name: String?
    public let originalName: String?
    public let size: Int64?
    public let fileHash: String?
    public let hashCode: String?
    public let parentHash: String?

    public init(
        fileExtension: String? = nil,
        link: String? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        originalName: String? = nil,
        size: Int64? = nil,
        fileHash: String? = nil,
        hashCode: String? = nil,
        parentHash: String? = nil,
        actualHeight: Int? = nil,
        actualWidth: Int? = nil
    ) {
        self.actualHeight = actualHeight
        self.actualWidth = actualWidth
        self.extension = fileExtension
        self.link = link
        self.mimeType = mimeType
        self.name = name
        self.originalName = originalName
        self.size = size
        self.fileHash = fileHash
        self.hashCode = hashCode
        self.parentHash = parentHash
    }
}
