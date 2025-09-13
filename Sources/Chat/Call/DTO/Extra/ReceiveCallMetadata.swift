//
// ReceiveCallMetadata.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct ReceiveCallMetadata: Decodable, Sendable {
    let id: CallMessageType
    let done: Bool
    let message: ReceiveCallMetadataMessage?
    let chatId: Int?
    let uniqueId: String

    public init(id: CallMessageType, done: Bool, message: ReceiveCallMetadataMessage?, chatId: Int? = nil, uniqueId: String) {
        self.id = id
        self.done = done
        self.message = message
        self.chatId = chatId
        self.uniqueId = uniqueId
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case done = "done"
        case message = "message"
        case chatId = "chatId"
        case uniqueId = "uniqueId"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        let done = try container.decode(String.self, forKey: .done)
        self.done = done == "TRUE"
        if let messageData = try container.decodeIfPresent(String.self, forKey: .message)?.data(using: .utf8) {
            self.message = try JSONDecoder.instance.decode(ReceiveCallMetadataMessage.self, from: messageData)
        } else {
            self.message = nil
        }
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
    }
}

public struct ReceiveCallMetadataMessage: Decodable, Sendable {
    let id: CallMetadataType
    let description: String?
    let userId: Int?
    let content: ReceiveMetadataMessageContent?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case dimension = "dimension"
        case description = "description"
        case userId = "userid"
        case content = "content"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMetadataType.self, forKey: .id)
        self.content = try container.decodeIfPresent(ReceiveMetadataMessageContent.self, forKey: .content)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId)
    }
}

public struct ReceiveMetadataMessageContent: Decodable, Sendable {
    
    public init(dimension: ScreenShareDimension? = nil) {
        self.dimension = dimension
    }
    
    let dimension: ScreenShareDimension?
    
    private enum CodingKeys: String, CodingKey {
        case dimension = "dimension"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dimension = try container.decodeIfPresent(ScreenShareDimension.self, forKey: .dimension)
    }
}

public struct ScreenShareDimension: Decodable, Sendable {
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case width = "width"
        case height = "height"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
    }
}

enum CallMetadataType: Int, Decodable {
    case poorconnection =  1
    case poorconnectionResolved =  2
    case customuserMetadata =  3
    case screenShareMetadata =  4
}
