//
// ReplyInfo.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ReplyInfo: Codable, Identifiable, Hashable, Sendable {
    public var id: Int? { repliedToMessageId }
    public var deleted: Bool?
    public var repliedToMessageId: Int?
    public var message: String?
    public var messageType: MessageType?
    public var metadata: String?
    public var systemMetadata: String?
    public var repliedToMessageNanos: UInt?
    public var repliedToMessageTime: UInt?
    public var participant: Participant?
    public var replyPrivatelyInfo: ReplyPrivatelyInfo?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedToMessageId = try container.decodeIfPresent(Int.self, forKey: .repliedToMessageId)
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        repliedToMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageNanos)
        repliedToMessageTime = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageTime)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        replyPrivatelyInfo = try container.decodeIfPresent(ReplyPrivatelyInfo.self, forKey: .replyPrivatelyInfoVO)
    }

    public init(
        deleted: Bool? = nil,
        repliedToMessageId: Int? = nil,
        message: String? = nil,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        systemMetadata: String? = nil,
        repliedToMessageNanos: UInt? = nil,
        repliedToMessageTime: UInt? = nil,
        participant: Participant? = nil
    ) {
        self.deleted = deleted
        self.repliedToMessageId = repliedToMessageId
        self.message = message
        self.messageType = messageType
        self.metadata = metadata
        self.systemMetadata = systemMetadata
        self.repliedToMessageNanos = repliedToMessageNanos
        self.repliedToMessageTime = repliedToMessageTime
        self.participant = participant
    }

    private enum CodingKeys: String, CodingKey {
        case deleted
        case message
        case messageType
        case metadata
        case repliedToMessageId
        case systemMetadata
        case repliedToMessageNanos
        case repliedToMessageTime
        case participant
        case replyPrivatelyInfoVO
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deleted, forKey: .deleted)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedToMessageId, forKey: .repliedToMessageId)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(repliedToMessageTime, forKey: .repliedToMessageTime)
        try container.encodeIfPresent(repliedToMessageNanos, forKey: .repliedToMessageNanos)
        try container.encodeIfPresent(participant, forKey: .participant)
    }
}
