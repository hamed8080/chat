//
// UploadImageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UploadImageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var data: Data
    public var fileExtension: String?
    public var fileName: String = ""
    public var fileSize: Int64 = 0
    /// if  send file iniside the thread we need to set is isPublic to false
    public private(set) var isPublic: Bool?
    public var mimeType: String = ""
    public var originalName: String = ""
    public var userGroupHash: String?
    public var description: String?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public var xC: Int = 0
    public var yC: Int = 0
    public var hC: Int = 0
    public var wC: Int = 0
    public var dataToSend: Data? { data }

    public init(data: Data,
                fileExtension: String? = nil,
                fileName: String = "",
                fileSize: Int64 = 0,
                isPublic: Bool? = nil,
                mimeType: String,
                originalName: String = "",
                userGroupHash: String? = nil,
                description: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0,
                xC: Int = 0,
                yC: Int = 0,
                hC: Int = 0,
                wC: Int = 0) {
        self.data = data
        self.fileExtension = fileExtension
        self.fileName = fileName
        self.fileSize = fileSize
        self.isPublic = isPublic
        self.mimeType = mimeType
        self.originalName = originalName
        self.userGroupHash = userGroupHash
        self.description = description
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = UUID().uuidString
        self.xC = xC
        self.yC = yC
        self.hC = hC
        self.wC = wC
    }

    internal init(data: Data,
                fileExtension: String? = nil,
                fileName: String = "",
                fileSize: Int64 = 0,
                isPublic: Bool? = nil,
                mimeType: String,
                originalName: String = "",
                userGroupHash: String? = nil,
                description: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0,
                uniqueId: String,
                xC: Int = 0,
                yC: Int = 0,
                hC: Int = 0,
                wC: Int = 0) {
        self.data = data
        self.fileExtension = fileExtension
        self.fileName = fileName
        self.fileSize = fileSize
        self.isPublic = isPublic
        self.mimeType = mimeType
        self.originalName = originalName
        self.userGroupHash = userGroupHash
        self.description = description
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = uniqueId
        self.xC = xC
        self.yC = yC
        self.hC = hC
        self.wC = wC
    }

    private enum CodingKeys: String, CodingKey {
        case userGroupHash
        case isPublic
        case filename
        case xC
        case yC
        case hC
        case wC
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(xC)", forKey: .xC)
        try container.encode("\(yC)", forKey: .yC)
        try container.encode("\(hC)", forKey: .hC)
        try container.encode("\(wC)", forKey: .wC)
        try container.encodeIfPresent("\(isPublic != nil && isPublic == true ? "true" : "false")", forKey: .isPublic) // dont send bool it crash when send and encode to dictionary
        try container.encodeIfPresent(fileName, forKey: .filename)
    }
}
