//
// ReplyPrivatelyRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ReplyPrivatelyRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var queueTime: Date = .init()
    public var messageType: MessageType
    public var metadata: String?
    public let repliedTo: Int?
    public let systemMetadata: String?
    public var uniqueId: String
    public let replyContent: ReplyPrivatelyContent
    public var typeCodeIndex: Index

    public init(repliedTo: Int,
                messageType: MessageType,
                metadata: String? = nil,
                content: ReplyPrivatelyContent,
                systemMetadata: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.messageType = messageType
        self.metadata = metadata
        self.repliedTo = repliedTo
        self.systemMetadata = systemMetadata
        self.uniqueId = UUID().uuidString
        self.replyContent = content
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case queueTime
        case messageType
        case metadata
        case repliedTo
        case systemMetadata
        case threadId
        case uniqueId
        case typeCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.queueTime, forKey: .queueTime)
        try container.encode(self.messageType, forKey: .messageType)
        try container.encodeIfPresent(self.metadata, forKey: .metadata)
        try container.encodeIfPresent(self.repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(self.systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(self.uniqueId, forKey: .uniqueId)
//        try container.encodeIfPresent(self.typeCode, forKey: .typeCode)
    }
}

public struct ReplyPrivatelyContent: Encodable, Sendable {
    public let text: String
    public let invitees: [Invitee]?
    public let targetConversationId: Int?
    public let fromConversationId: Int

    public init(text: String, targetConversationId: Int, fromConversationId: Int) {
        self.text = text
        self.fromConversationId = fromConversationId
        self.targetConversationId = targetConversationId
        invitees = nil
    }

    public init(text: String, invitee: Invitee, fromConversationId: Int) {
        self.text = text
        self.fromConversationId = fromConversationId
        self.invitees = [invitee]
        targetConversationId = nil
    }

    enum CodingKeys: String, CodingKey {
        case text
        case invitees
        case targetConversationId = "targetThreadId"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.text, forKey: .text)
        try container.encodeIfPresent(self.invitees, forKey: .invitees)
        try container.encodeIfPresent(self.targetConversationId, forKey: .targetConversationId)
    }
}
