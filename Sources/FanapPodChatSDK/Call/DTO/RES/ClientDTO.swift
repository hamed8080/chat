//
// ClientDTO.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct ClientDTO: Codable {
    public let clientId: String
    public let topicReceive: String?
    public let topicSend: String
    public let desc: String?
    public let sendKey: String?
    public let video: Bool
    public let mute: Bool
    public let userId: Int

    public init(clientId: String, topicReceive: String?, topicSend: String, userId: Int, desc: String?, sendKey: String?, video: Bool, mute: Bool) {
        self.clientId = clientId
        self.topicReceive = topicReceive
        self.topicSend = topicSend
        self.userId = userId
        self.desc = desc
        self.sendKey = sendKey
        self.video = video
        self.mute = mute
    }
}
