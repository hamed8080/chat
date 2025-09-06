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
    let clientId: Int?
    let chatId: Int?
    let uniqueId: String
    let desc: String?
    
    public init(id: CallMessageType, done: Bool, clientId: Int?, chatId: Int?, desc: String? = nil, uniqueId: String) {
        self.id = id
        self.done = done
        self.clientId = clientId
        self.chatId = chatId
        self.desc = desc
        self.uniqueId = uniqueId
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case done = "done"
        case clientId = "clientId"
        case chatId = "chatId"
        case desc = "desc"
        case uniqueId = "uniqueId"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        let done = try container.decode(String.self, forKey: .done)
        self.done = done == "TRUE"
        
        if let clientId = try container.decodeIfPresent(String.self, forKey: .clientId) {
            guard let clientId = Int(clientId) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .chatId,
                    in: container,
                    debugDescription: "clientId must be an Int in String format"
                )
            }
            self.clientId = clientId
        } else {
            self.clientId = nil
        }
        
        if let chatId = try container.decodeIfPresent(String.self, forKey: .chatId) {
            guard let chatId = Int(chatId) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .chatId,
                    in: container,
                    debugDescription: "chatId must be an Int in String format"
                )
            }
            self.chatId = chatId
        } else {
            self.chatId = nil
        }
        
        self.uniqueId = try container.decode(String.self, forKey: .uniqueId)
    }
}
