//
// SendCandidateReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendCandidateReq: Encodable, AsyncSnedable {
    let id: CallMessageType = .sendIceCandidate
    let token: String
    let chatId: Int
    let brokerAddress: String
    let iceCandidate: IceCandidate
    let uniqueId: String = UUID().uuidString
    
    var asyncMessageType: AsyncMessageTypes? = .message
    var content: String? { jsonString }
    var peerName: String?

    public init(peerName: String, token: String, iceCandidate: IceCandidate, brokerAddress: String, chatId: Int) {
        self.peerName = peerName
        self.token = token
        self.iceCandidate = iceCandidate
        self.chatId = chatId
        self.brokerAddress = brokerAddress
    }

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case token = "token"
        case chatId = "chatId"
        case iceCandidate = "iceCandidate"
        case uniqueId = "uniqueId"
        case brokerAddress = "brokerAddress"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.chatId, forKey: .chatId)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.iceCandidate, forKey: .iceCandidate)
        try container.encode(self.uniqueId, forKey: .uniqueId)
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
    }
}
