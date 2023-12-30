//
// CreateThreadWithMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public class CreateThreadWithMessage: CreateThreadRequest {
    public var message: CreateThreadMessage

    public init(description: String?,
                image: String?,
                invitees: [Invitee],
                metadata: String?,
                title: String,
                type: ThreadTypes?,
                uniqueName: String?,
                message: CreateThreadMessage,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.message = message
        super.init(description: description,
                   image: image,
                   invitees: invitees,
                   metadata: metadata,
                   title: title,
                   type: type,
                   uniqueName: uniqueName,
                   uniqueId: nil,
                   typeCodeIndex: typeCodeIndex)
    }

    private enum CodingKeys: String, CodingKey {
        case message
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
    }
}

public class CreateThreadMessage: Encodable {
    public let forwardedMessageIds: [String]?
    public var forwardedUniqueIds: [String]?
    public let repliedTo: Int?
    public let text: String?
    public let messageType: MessageType
    var metadata: String?
    public let systemMetadata: String?

    public init(forwardedMessageIds: [String]? = nil,
                repliedTo: Int? = nil,
                text: String? = nil,
                messageType: MessageType,
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
