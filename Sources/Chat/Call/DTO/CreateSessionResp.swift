//
//  CreateSessionResp.swift
//  Chat
//
//  Created by Hamed Hosseini on 8/31/25.
//

import Foundation

public struct CreateSessionResp: Decodable {
    let id: CallMessageType
    let done: Bool
    let clientId: Int
    let chatId: Int
    let uniqueId: String
    
    public init(id: CallMessageType, done: Bool, clientId: Int, chatId: Int, uniqueId: String) {
        self.id = id
        self.done = done
        self.clientId = clientId
        self.chatId = chatId
        self.uniqueId = uniqueId
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case done = "done"
        case clientId = "clientId"
        case chatId = "chatId"
        case uniqueId = "uniqueId"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        let done = try container.decode(String.self, forKey: .done)
        self.done = done == "TRUE"
        
        let clientId = try container.decode(String.self, forKey: .clientId)
        guard let clientId = Int(clientId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .chatId,
                in: container,
                debugDescription: "clientId must be an Int in String format"
            )
        }
        self.clientId = clientId
        
        let chatId = try container.decode(String.self, forKey: .chatId)
        guard let chatId = Int(chatId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .chatId,
                in: container,
                debugDescription: "chatId must be an Int in String format"
            )
        }
        self.chatId = chatId
        
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
    }
}
