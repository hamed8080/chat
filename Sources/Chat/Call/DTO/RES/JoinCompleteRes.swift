//
// JoinCompleteRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct JoinCompleteRes: Decodable {
    let id: CallMessageType
    let chatId: Int
    let topic: [Addition]
    let uniqueId: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
        
        let chatId = try container.decode(String.self, forKey: .chatId)
        guard let chatId = Int(chatId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .chatId,
                in: container,
                debugDescription: "chatId must be an Int in String format"
            )
        }
        self.chatId = chatId
        
        guard let topicString = try container.decode(String.self, forKey: .topic).data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(
                forKey: .topic,
                in: container,
                debugDescription: "topic string is not valid UTF-8"
            )
        }
        self.topic = try JSONDecoder().decode([Addition].self, from: topicString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case uniqueId = "uniqueId"
        case chatId = "chatId"
        case topic = "topic"
    }
}
