//
// UpdateThreadInfoRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UpdateThreadInfoRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let description: String?
    public var metadata: String?
    public var threadImage: UploadImageRequest?
    public let threadId: Int
    public let title: String?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(description: String? = nil,
                metadata: String? = nil,
                threadId: Int,
                threadImage: UploadImageRequest? = nil,
                title: String,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.description = description
        self.metadata = metadata
        self.threadId = threadId
        self.threadImage = threadImage
        self.title = title
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case description
        case name
        case metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(title, forKey: .name)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
