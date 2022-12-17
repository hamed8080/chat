//
// ChatMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

struct ChatMessage: Decodable {
    var code: Int?
    let content: String?
    let contentCount: Int?
    var message: String?
    let messageType: Int
    let subjectId: Int?
    let time: Int
    let type: ChatMessageVOTypes
    let uniqueId: String
    var messageId: Int?
    var participantId: Int?
    var typeCode: String?

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

    init(from decoder: Decoder) throws {
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
