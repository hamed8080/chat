//
//  QueueOfEditMessages.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class QueueOfEditMessages: Codable, Hashable, Identifiable {
    public static func == (lhs: QueueOfEditMessages, rhs: QueueOfEditMessages) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }

    public var messageId: Int?
    public var messageType: MessageType?
    public var metadata: String?
    public var repliedTo: Int?
    public var textMessage: String?
    public var threadId: Int?
    public var typeCode: String?
    public var uniqueId: String?

    private enum CodingKeys: String, CodingKey {
        case messageId
        case messageType
        case metadata
        case repliedTo
        case textMessage
        case threadId
        case typeCode
        case uniqueId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedTo = try container.decodeIfPresent(Int.self, forKey: .repliedTo)
        textMessage = try container.decodeIfPresent(String.self, forKey: .textMessage)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
    }

    public init(
        messageId: Int? = nil,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        repliedTo: Int? = nil,
        textMessage: String? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueId: String? = nil
    ) {
        self.messageId = messageId
        self.messageType = messageType
        self.metadata = metadata
        self.repliedTo = repliedTo
        self.textMessage = textMessage
        self.threadId = threadId
        self.typeCode = typeCode
        self.uniqueId = uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageId, forKey: .messageId)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(textMessage, forKey: .textMessage)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }

    init(edit: EditMessageRequest) {
        messageId = edit.messageId
        messageType = edit.messageType
        metadata = edit.metadata
        repliedTo = edit.repliedTo
        textMessage = edit.textMessage
        threadId = edit.threadId
        typeCode = edit.typeCode
        uniqueId = edit.uniqueId
    }

    var request: EditMessageRequest {
        EditMessageRequest(threadId: threadId ?? -1,
                           messageType: messageType ?? .unknown,
                           messageId: messageId ?? -1,
                           textMessage: textMessage ?? "",
                           repliedTo: repliedTo,
                           metadata: metadata,
                           uniqueId: uniqueId)
    }
}
