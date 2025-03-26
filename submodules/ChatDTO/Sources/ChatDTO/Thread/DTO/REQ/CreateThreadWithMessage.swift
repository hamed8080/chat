//
// CreateThreadWithMessage.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct CreateThreadWithMessage: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let description: String?
    public let image: String?
    public let invitees: [Invitee]?
    public let metadata: String?
    public let title: String
    public let type: ThreadTypes?
    public let uniqueName: String? // only for public thread
    public let uniqueId: String
    public var message: CreateThreadMessage
    public var typeCodeIndex: Index

    public init(description: String? = nil,
         image: String? = nil,
         invitees: [Invitee]? = nil,
         metadata: String? = nil,
         title: String,
         type: ThreadTypes? = nil,
         uniqueName: String? = nil,
         message: CreateThreadMessage,
         typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.description = description
        self.image = image
        self.invitees = invitees
        self.metadata = metadata
        self.title = title
        self.type = type
        self.uniqueName = uniqueName
        self.uniqueId = UUID().uuidString
        self.message = message
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case message
        case title
        case image
        case description
        case metadata
        case uniqueName
        case type
        case invitees
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(uniqueName, forKey: .uniqueName)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(invitees, forKey: .invitees)
    }
}

public struct CreateThreadMessage: Encodable, Sendable {
    public let forwardedMessageIds: [String]?
    public var forwardedUniqueIds: [String]?
    public let repliedTo: Int?
    public let text: String?
    public let messageType: ChatModels.MessageType
    var metadata: String?
    public let systemMetadata: String?

    public init(forwardedMessageIds: [String]? = nil,
                repliedTo: Int? = nil,
                text: String? = nil,
                messageType: ChatModels.MessageType,
                systemMetadata: String? = nil)
    {
        self.forwardedMessageIds = forwardedMessageIds
        self.repliedTo = repliedTo
        self.text = text
        self.messageType = messageType
        metadata = nil
        self.systemMetadata = systemMetadata

        forwardedMessageIds?.forEach { _ in
            self.forwardedUniqueIds?.append(UUID().uuidString)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case forwardedMessageIds
        case forwardedUniqueIds
        case repliedTo
        case text
        case metadata
        case systemMetadata
        case messageType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(forwardedMessageIds, forKey: .forwardedMessageIds)
        try container.encodeIfPresent(forwardedUniqueIds, forKey: .forwardedUniqueIds)
        try container.encodeIfPresent(repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(messageType, forKey: .messageType)
    }
}
