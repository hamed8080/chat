//
//  QueueOfForwardMessages.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class QueueOfForwardMessages: Codable, Hashable, Identifiable {
    public static func == (lhs: QueueOfForwardMessages, rhs: QueueOfForwardMessages) -> Bool {
        lhs.fromThreadId == rhs.fromThreadId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fromThreadId)
    }

    public var fromThreadId: Int?
    public var messageIds: [Int]?
    public var threadId: Int?
    public var typeCode: String?
    public var uniqueIds: [String]?

    private enum CodingKeys: String, CodingKey {
        case fromThreadId
        case messageIds
        case threadId
        case typeCode
        case uniqueIds
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fromThreadId = try container.decodeIfPresent(Int.self, forKey: .fromThreadId)
        messageIds = try container.decodeIfPresent([Int].self, forKey: .messageIds)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
    }

    public init(
        fromThreadId: Int? = nil,
        messageIds: [Int]? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueIds: [String]? = nil
    ) {
        self.fromThreadId = fromThreadId
        self.messageIds = messageIds
        self.threadId = threadId
        self.typeCode = typeCode
        self.uniqueIds = uniqueIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fromThreadId, forKey: .fromThreadId)
        try container.encodeIfPresent(messageIds, forKey: .messageIds)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueIds, forKey: .uniqueIds)
    }

    public init(forward: ForwardMessageRequest) {
        fromThreadId = forward.fromThreadId
        messageIds = forward.messageIds
        threadId = forward.threadId
        typeCode = forward.typeCode
        uniqueIds = forward.uniqueIds
    }

    var request: ForwardMessageRequest {
        ForwardMessageRequest(fromThreadId: fromThreadId ?? -1,
                              threadId: threadId ?? -1,
                              messageIds: messageIds ?? [],
                              uniqueIds: uniqueIds ?? [])
    }
}
