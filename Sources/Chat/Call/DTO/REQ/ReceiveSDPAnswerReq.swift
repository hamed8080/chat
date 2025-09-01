//
// ReceiveSDPAnswerReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Chat
import ChatCore
import Foundation

struct ReceiveSDPAnswerReq: Encodable, AsyncSnedable {
    let id: CallMessageType
    var brokerAddress: String
    var token: String
    var sdpAnswer: String
    var chatId: Int?
    let addition: [Addition]
    let uniqueId = UUID().uuidString

    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message
    var peerName: String?
    
    public init(
        id: CallMessageType, sdpAnswer: String, addition: [Addition], peerName: String, brokerAddress: String,
        token: String, chatId: Int?
    ) {
        self.id = id
        self.peerName = peerName
        self.brokerAddress = brokerAddress
        self.token = token
        self.sdpAnswer = sdpAnswer
        self.chatId = chatId
        self.addition = addition
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case brokerAddress = "brokerAddress"
        case token = "token"
        case sdpAnswer = "sdpAnswer"
        case chatId = "chatId"
        case peerName = "peerName"
        case addition = "addition"
        case uniqueId = "uniqueId"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.sdpAnswer, forKey: .sdpAnswer)
        try container.encodeIfPresent(self.chatId, forKey: .chatId)
        try container.encodeIfPresent(self.peerName, forKey: .peerName)
        try container.encode(self.addition, forKey: .addition)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
