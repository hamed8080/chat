//
// ReceiveMediaItem.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct ReceiveMediaItem: Decodable {
    let id: Int
    let chatId: Int
    let clientId: Int
    let mline: Int
    let topic: String
    let mediaType: ReveiveMediaItemType
    let isReceiving: Bool
    let version: Int
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.clientId = try container.decode(Int.self, forKey: .clientId)
        self.mline = try container.decode(Int.self, forKey: .mline)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.mediaType = try container.decode(ReveiveMediaItemType.self, forKey: .mediaType)
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

extension ReceiveMediaItem {
    var toAddition: Addition {
        .init(
            mline: mline,
            clientId: clientId,
            topic: topic,
            mediaType: mediaType == .audio ? .audio : .video
        )
    }
}

enum ReveiveMediaItemType: Int, Codable {
    case video = 0
    case audio = 1
    case screenShare = 2
}
