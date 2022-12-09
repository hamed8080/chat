//
// CreateSessionReq.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  CreateSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import FanapPodAsyncSDK
import Foundation

class CreateSessionReq: UniqueIdManagerRequest, AsyncSnedable {
    var id: String = "CREATE_SESSION"
    var brokerAddress: String
    var turnAddress: String
    var token: String
    var peerName: String?
    var content: String? { convertCodableToString() }
    var asyncMessageType: AsyncMessageTypes? = .message

    public init(peerName: String, id: String = "CREATE_SESSION", turnAddress: String, brokerAddress: String, token: String, uniqueId: String? = nil) {
        self.id = id
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
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(turnAddress, forKey: .turnAddress)
        try container.encode(brokerAddress, forKey: .brokerAddress)
        try container.encode(token, forKey: .token)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }
}
