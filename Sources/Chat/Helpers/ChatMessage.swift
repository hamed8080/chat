//
// ChatMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import Foundation

public struct ChatMessage: Decodable {
    public var code: Int?
    public let content: String?
    public let contentCount: Int?
    public var message: String?
    public let messageType: Int
    public let subjectId: Int?
    public let time: Int
    public let type: ChatMessageVOTypes
    public let uniqueId: String
    public var messageId: Int?
    public var participantId: Int?
    public var typeCode: String?

    private enum CodingKeys: String, CodingKey {
        case code
        case content
        case contentCount
        case message
        case messageType
        case subjectId
        case time
        case type
        case uniqueId
        case messageId
        case participantId
        case typeCode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try? container.decode(Int.self, forKey: .code)
        content = try? container.decode(String.self, forKey: .content)
        contentCount = try? container.decode(Int.self, forKey: .contentCount)
        message = try? container.decode(String.self, forKey: .message)
        messageType = try container.decode(Int.self, forKey: .messageType)
        subjectId = try? container.decode(Int.self, forKey: .subjectId)
        time = try container.decode(Int.self, forKey: .time)
        type = try container.decode(ChatMessageVOTypes.self, forKey: .type)
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        if let uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId) {
            self.uniqueId = uniqueId
        } else {
            uniqueId = "" // some messages like system message type = 46 dont have unique id
        }
        messageId = try? container.decode(Int.self, forKey: .messageId)
        participantId = try? container.decode(Int.self, forKey: .participantId)
    }
}
