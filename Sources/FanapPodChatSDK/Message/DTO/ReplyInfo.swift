//
// ReplyInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  ReplyInfo.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//
import Foundation

open class ReplyInfo: Codable {
    public var deleted: Bool?
    public var repliedToMessageId: Int?
    public var message: String?
    public var messageType: Int?
    public var metadata: String?
    public var systemMetadata: String?
    public var repliedToMessageTime: UInt?
    public var repliedToMessageNanos: UInt?
    public var time: UInt?
    public var participant: Participant?

    public init(deleted: Bool?,
                repliedToMessageId: Int?,
                message: String?,
                messageType: Int?,
                metadata: String?,
                systemMetadata: String?,
                time: UInt?,
                participant: Participant?)
    {
        self.deleted = deleted
        self.repliedToMessageId = repliedToMessageId
        self.message = message
        self.messageType = messageType
        self.metadata = metadata
        self.systemMetadata = systemMetadata
        self.time = time
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
        case time
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageType = try container.decodeIfPresent(Int.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedToMessageId = try container.decodeIfPresent(Int.self, forKey: .repliedToMessageId)
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        repliedToMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageNanos)
        repliedToMessageTime = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageTime)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        if let repliedToMessageTime = repliedToMessageTime, let repliedToMessageNanos = repliedToMessageNanos {
            time = (UInt(repliedToMessageTime / 1000) * 1_000_000_000) + repliedToMessageNanos
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deleted, forKey: .deleted)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedToMessageId, forKey: .repliedToMessageId)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(participant, forKey: .participant)
    }
}
