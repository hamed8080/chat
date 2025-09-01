//
// CallSubscribeRequest.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Chat
import ChatCore
import Foundation

struct CallSubscribeRequest: Encodable, AsyncSnedable {
    let id: CallMessageType
    let chatId: Int
    let token: String
    let brokerAddress: String
    let addition: [Addition]
    let uniqueId = UUID().uuidString

    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message
    let peerName: String?

    init(
        id: CallMessageType, chatId: Int, token: String, brokerAddress: String,
        addition: [Addition], peerName: String?
    ) {
        self.id = id
        self.chatId = chatId
        self.token = token
        self.brokerAddress = brokerAddress
        self.addition = addition
        self.peerName = peerName
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case token = "token"
        case chatId = "chatId"
        case uniqueId = "uniqueId"
        case addition = "addition"
        case brokerAddress = "brokerAddress"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(token, forKey: .token)
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(addition, forKey: .addition)
        try container.encode(chatId, forKey: .chatId)
        try container.encode(brokerAddress, forKey: .brokerAddress)
    }
}
