//
// AddIceCandidateRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct AddIceCandidateRes: Decodable {
    let id: CallMessageType
    let chatId: Int
    let candidate: IceCandidate
    let uniqueId: String

    public init(id: CallMessageType, candidate: IceCandidate, chatId: Int, uniqueId: String) {
        self.id = id
        self.candidate = candidate
        self.chatId = chatId
        self.uniqueId = uniqueId
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case chatId = "chatId"
        case candidate = "candidate"
        case uniqueId = "uniqueId"
    }
   
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(CallMessageType.self, forKey: .id)
        
        let candidateString = try container.decode(String.self, forKey: .candidate).data
        
        guard let candidateData = try container.decode(String.self, forKey: .candidate).data(using: .utf8) else {
            throw DecodingError.dataCorruptedError(
                forKey: .candidate,
                in: container,
                debugDescription: "candidate string is not valid UTF-8"
            )
        }
        self.candidate = try JSONDecoder().decode(IceCandidate.self, from: candidateData)
        
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
