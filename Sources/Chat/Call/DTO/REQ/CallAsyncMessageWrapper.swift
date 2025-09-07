//
// CallAsyncMessageWrapper.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import ChatCore
import Foundation

struct CallAsyncMessageWrapper: AsyncSnedable {
    let content: String?
    let peerName: String?
    var asyncMessageType: AsyncMessageTypes?
    
    init(content: String, peerName: String, type: AsyncMessageTypes = .message) {
        self.content = content
        self.peerName = peerName
        self.asyncMessageType = type
    }
}

struct CallServerWrapper<T: Encodable>: Encodable {
    let id: CallMessageType
    let token: String
    let uniqueId: String = UUID().uuidString
    let chatId: Int
    let payload: T
    
    init(id: CallMessageType,
         token: String,
         chatId: Int,
         payload: T) {
        self.id = id
        self.token = token
        self.chatId = chatId
        self.payload = payload
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case uniqueId = "uniqueId"
        case token = "token"
        case chatId = "chatId"
    }
       
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(token, forKey: .token)
        try container.encode(chatId, forKey: .chatId)
        
        // Dynamically encode payload *at root level*
        try payload.encode(to: encoder)
    }
}
