//
// EditMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct EditMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var queueTime: Date = .init()
    public var messageType: MessageType
    public let repliedTo: Int?
    public let messageId: Int
    public let textMessage: String
    public let metadata: String?
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int,
                messageType: MessageType,
                messageId: Int,
                textMessage: String,
                repliedTo: Int? = nil,
                metadata: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.threadId = threadId
        self.messageType = messageType
        self.repliedTo = repliedTo
        self.messageId = messageId
        self.textMessage = textMessage
        self.metadata = metadata
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    internal init(threadId: Int,
                messageType: MessageType,
                messageId: Int,
                textMessage: String,
                repliedTo: Int? = nil,
                metadata: String? = nil,
                uniqueId: String,
                  typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.threadId = threadId
        self.messageType = messageType
        self.repliedTo = repliedTo
        self.messageId = messageId
        self.textMessage = textMessage
        self.metadata = metadata
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case queueTime
        case messageType
        case repliedTo
        case messageId
        case textMessage
        case metadata
        case threadId
        case uniqueId
        case typeCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.queueTime, forKey: .queueTime)
        try container.encode(self.messageType, forKey: .messageType)
        try container.encodeIfPresent(self.repliedTo, forKey: .repliedTo)
        try container.encode(self.messageId, forKey: .messageId)
        try container.encode(self.textMessage, forKey: .textMessage)
        try container.encodeIfPresent(self.metadata, forKey: .metadata)
        try container.encode(self.threadId, forKey: .threadId)
//        try container.encodeIfPresent(self.uniqueId, forKey: .uniqueId)
    }
}
