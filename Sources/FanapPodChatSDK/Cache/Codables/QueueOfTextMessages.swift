//
//  QueueOfTextMessages.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class QueueOfTextMessages: Codable, Identifiable, Hashable {
    public static func == (lhs: QueueOfTextMessages, rhs: QueueOfTextMessages) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }

    public var messageType: MessageType?
    public var metadata: String?
    public var repliedTo: Int?
    public var systemMetadata: String?
    public var textMessage: String?
    public var threadId: Int?
    public var typeCode: String?
    public var uniqueId: String?

    private enum CodingKeys: String, CodingKey {
        case messageType
        case metadata
        case repliedTo
        case systemMetadata
        case textMessage
        case threadId
        case typeCode
        case uniqueId
    }

    public init(
        messageType: MessageType? = nil,
        metadata: String? = nil,
        repliedTo: Int? = nil,
        systemMetadata: String? = nil,
        textMessage: String? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueId: String? = nil
    ) {
        self.messageType = messageType
        self.metadata = metadata
        self.repliedTo = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage = textMessage
        self.threadId = threadId
        self.typeCode = typeCode
        self.uniqueId = uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedTo, forKey: .repliedTo)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(textMessage, forKey: .textMessage)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }

    public init(textRequest: SendTextMessageRequest) {
        messageType = textRequest.messageType
        metadata = textRequest.metadata
        repliedTo = textRequest.repliedTo
        systemMetadata = textRequest.systemMetadata
        textMessage = textRequest.textMessage
        threadId = textRequest.threadId
        typeCode = textRequest.typeCode
        uniqueId = textRequest.uniqueId
    }

    var request: SendTextMessageRequest {
        SendTextMessageRequest(threadId: threadId ?? -1,
                               textMessage: textMessage ?? "",
                               messageType: messageType ?? .unknown,
                               metadata: metadata,
                               repliedTo: repliedTo,
                               systemMetadata: systemMetadata,
                               uniqueId: uniqueId)
    }
}
