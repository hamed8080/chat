//
// ReceivingMedia.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct ReceivingMedia: Decodable {
    let id: CallMessageType
    let chatId: Int
    let recvList: [ReceiveMediaItem]
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
        
        guard let recvListData = try container.decode(String.self, forKey: .recvList).data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(
                forKey: .recvList,
                in: container,
                debugDescription: "recvList string is not valid UTF-8"
            )
        }
        self.recvList = try JSONDecoder().decode([ReceiveMediaItem].self, from: recvListData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case uniqueId = "uniqueId"
        case chatId = "chatId"
        case recvList = "recvList"
    }
}

struct ReceiveMediaItem: Decodable {
    let id: Int
    let chatId: Int
    let clientId: Int
    let mline: Int
    let topic: String
    let mediaType: MediaType
    let isReceiving: Bool
    let version: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.clientId = try container.decode(Int.self, forKey: .clientId)
        self.mline = try container.decode(Int.self, forKey: .mline)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        self.isReceiving = try container.decode(Int.self, forKey: .isReceiving) == 1
        self.version = try container.decode(Int.self, forKey: .version)
        
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
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case clientId = "clientId"
        case mline = "mline"
        case topic = "topic"
        case mediaType = "mediaType"
        case isReceiving = "isReceiving"
        case chatId = "chatId"
        case version = "version"
    }
}
