//
// SendOfferSDPReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendOfferSDPReq: Codable, AsyncSnedable {
    let id: CallMessageType
    var brokerAddress: String
    var token: String
    var sdpOffer: String
    var chatId: Int?
    let addition: [Addition]
    let uniqueId = UUID().uuidString
    
    var peerName: String?
    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message
    
    public init(id: CallMessageType, peerName: String, brokerAddress: String, token: String, topic: String, sdpOffer: String, mediaType: MediaType, chatId: Int?) {
        self.id = id
        self.peerName = peerName
        self.brokerAddress = brokerAddress
        self.token = token
        self.sdpOffer = sdpOffer
        self.chatId = chatId
        self.addition = [Addition(mline: 0, clientId: nil, topic: topic, mediaType: mediaType)]
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case brokerAddress = "brokerAddress"
        case token = "token"
        case sdpOffer = "sdpOffer"
        case chatId = "chatId"
        case addition = "addition"
        case uniqueId = "uniqueId"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.sdpOffer, forKey: .sdpOffer)
        try container.encodeIfPresent(self.chatId, forKey: .chatId)
        try container.encode(self.addition, forKey: .addition)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}

