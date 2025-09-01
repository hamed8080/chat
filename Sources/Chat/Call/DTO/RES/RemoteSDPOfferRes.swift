//
//  RemoteSDPOfferRes.swift
//  Chat
//
//  Created by Hamed Hosseini on 9/1/25.
//

import Foundation
import WebRTC

public struct RemoteSDPOfferRes: Decodable {
    let id: CallMessageType
    let sdpOffer: String
    let addition: [Addition]
    let deletion: [Deletion]
    let operation: Operation
    let sdpVersion: Int
    let uniqueId: String
    let chatId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case sdpOffer = "sdpOffer"
        case sdpVersion = "sdpVersion"
        case uniqueId = "uniqueId"
        case chatId = "chatId"
        case operation = "operation"
        case topic = "topic"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        self.sdpOffer = try container.decode(String.self, forKey: .sdpOffer)
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
        self.sdpVersion = try container.decode(Int.self, forKey: .sdpVersion)
        self.operation = try container.decode(Operation.self, forKey: .operation)
        
        
        if let additionData = try container.decode(String.self, forKey: .topic).data(using: .utf8), operation == .addition {
            self.addition = try JSONDecoder().decode([Addition].self, from: additionData)
        } else {
            self.addition = []
        }
        
        if let deletionData = try container.decode(String.self, forKey: .topic).data(using: .utf8), operation == .deletion {
            self.deletion = try JSONDecoder().decode([Deletion].self, from: deletionData)
        } else {
            self.deletion = []
        }
        
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
    
    enum Operation: String, Decodable {
        case addition = "addition"
        case deletion = "deletion"
    }
}
