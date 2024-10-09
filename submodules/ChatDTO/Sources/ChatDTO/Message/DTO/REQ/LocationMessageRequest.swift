//
// LocationMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct LocationMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let mapCenter: Coordinate
    public let mapHeight: Int
    public let mapType: String
    public let mapWidth: Int
    public let mapZoom: Int
    public let mapImageName: String?

    public let repliedTo: Int?
    public let systemMetadata: String?
    public let textMessage: String?
    public let threadId: Int
    public let userGroupHash: String
    public let messageType: MessageType
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(mapCenter: Coordinate,
                threadId: Int,
                userGroupHash: String,
                mapHeight: Int = 500,
                mapType: String = "standard-night",
                mapWidth: Int = 800,
                mapZoom: Int = 15,
                mapImageName: String? = nil,
                repliedTo: Int? = nil,
                systemMetadata: String? = nil,
                textMessage: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.mapCenter = mapCenter
        self.mapHeight = mapHeight
        self.mapType = mapType
        self.mapWidth = mapWidth
        self.mapZoom = mapZoom

        self.mapImageName = mapImageName
        self.repliedTo = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage = textMessage
        self.threadId = threadId
        self.userGroupHash = userGroupHash
        messageType = MessageType.picture
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case mapCenter
        case mapHeight
        case mapType
        case mapWidth
        case mapZoom
        case mapImageName
        case repliedTo
        case systemMetadata
        case textMessage
        case threadId
        case userGroupHash
        case messageType
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.mapCenter, forKey: .mapCenter)
        try container.encode(self.mapHeight, forKey: .mapHeight)
        try container.encode(self.mapType, forKey: .mapType)
        try container.encode(self.mapWidth, forKey: .mapWidth)
        try container.encode(self.mapZoom, forKey: .mapZoom)
        try container.encodeIfPresent(self.mapImageName, forKey: .mapImageName)
        try container.encodeIfPresent(self.repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(self.systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(self.textMessage, forKey: .textMessage)
        try container.encode(self.threadId, forKey: .threadId)
        try container.encode(self.userGroupHash, forKey: .userGroupHash)
        try container.encode(self.messageType, forKey: .messageType)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
