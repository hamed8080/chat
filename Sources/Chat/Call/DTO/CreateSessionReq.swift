//
// CreateSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

class CreateSessionReq: UniqueIdManagerRequest, AsyncSnedable {
    var id: String = "CREATE_SESSION"
    var brokerAddress: String
    var turnAddress: String
    var token: String
    var peerName: String?
    let chatId: Int
    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message

    public init(peerName: String, id: String = "CREATE_SESSION", turnAddress: String, brokerAddress: String, chatId: Int, token: String, uniqueId: String? = nil) {
        self.id = id
        self.chatId = chatId
        self.peerName = peerName
        self.turnAddress = turnAddress
        self.brokerAddress = brokerAddress
        self.token = token
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case turnAddress
        case brokerAddress
        case token
        case uniqueId
        case chatId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(turnAddress, forKey: .turnAddress)
        try container.encode(brokerAddress, forKey: .brokerAddress)
        try container.encode(token, forKey: .token)
        try container.encode(chatId, forKey: .chatId)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }
}
