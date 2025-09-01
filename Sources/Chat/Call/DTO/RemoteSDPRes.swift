//
// RemoteSDPRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC

public struct RemoteSDPRes: Codable {
    let id: CallMessageType
    let sdpAnswer: String?
    let addition: [Addition]
    let deletion: [Deletion]
    let uniqueId: String
    let chatId: Int

    var rtcSDP: RTCSessionDescription? {
        guard let sdpString = sdpAnswer else { return nil }
        return RTCSessionDescription(type: .answer, sdp: sdpString)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case sdpAnswer = "sdpAnswer"
        case addition = "addition"
        case deletion = "deletion"
        case uniqueId = "uniqueId"
        case chatId = "chatId"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        self.sdpAnswer = try container.decodeIfPresent(String.self, forKey: .sdpAnswer)
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
        
        guard let additionData = try container.decode(String.self, forKey: .addition).data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(
                forKey: .addition,
                in: container,
                debugDescription: "addition string is not valid UTF-8"
            )
        }
        
        self.addition = try JSONDecoder().decode([Addition].self, from: additionData)
        
        guard let deletionData = try container.decode(String.self, forKey: .deletion).data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(
                forKey: .deletion,
                in: container,
                debugDescription: "deletion string is not valid UTF-8"
            )
        }
        self.deletion = try JSONDecoder().decode([Deletion].self, from: deletionData)
        
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
    
    struct Addition: Codable {
        let mline: Int
        let topic: String
        let mediaType: Mediatype
        let mids: [String]
    }
    
    struct Deletion: Codable {
        let mline: Int
        let topic: String
        let mediaType: Mediatype
        let mids: [String]
    }
}
