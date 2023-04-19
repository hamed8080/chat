//
// LocationMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/16/22

import Foundation
import ChatCore

public final class LocationMessageRequest: UniqueIdManagerRequest {
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
                uniqueId: String? = nil)
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
        super.init(uniqueId: uniqueId)
    }
}
