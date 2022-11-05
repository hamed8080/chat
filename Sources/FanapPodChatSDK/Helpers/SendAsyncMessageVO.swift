//
// SendAsyncMessageVO.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public struct SendAsyncMessageVO: Encodable {
    public init(content: String, ttl: Int, peerName: String, priority: Int = 1, pushMsgType: AsyncMessageTypes? = nil) {
        self.content = content
        self.ttl = ttl
        self.peerName = peerName
        self.priority = priority
        self.pushMsgType = pushMsgType
    }

    let content: String
    let ttl: Int
    let peerName: String
    var priority: Int = 1
    var pushMsgType: AsyncMessageTypes?

    private enum CodingKeys: String, CodingKey {
        case content
        case ttl
        case peerName
        case priority
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(content, forKey: .content)
        try? container.encodeIfPresent(ttl, forKey: .ttl)
        try? container.encodeIfPresent(peerName, forKey: .peerName)
        try? container.encodeIfPresent(priority, forKey: .priority)
    }
}
