//
// WebRTCConfig.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct WebRTCConfig {
    public let callConfig: CallConfig
    public let peerName: String
    public let iceServers: [String]
    public let turnAddress: String
    public let brokerAddressWeb: String
    public let topicSend: String?
    public let topicReceive: String?
    public let dataChannel: Bool
    public let customFrameCapturer: Bool
    public let userName: String?
    public let password: String?
    public let callId: Int?

    /// File for simulator
    public let fileName: String?

    var firstBorokerAddressWeb: String {
        if let firstBrokerAddressWeb = brokerAddressWeb.split(separator: ",").first {
            return String(firstBrokerAddressWeb)
        } else {
            return ""
        }
    }

    public init(callConfig: CallConfig, startCall: StartCall, isSendVideoEnabled _: Bool, fileName: String? = nil) {
        self.callConfig = callConfig
        callId = startCall.callId
        peerName = startCall.chatDataDto.kurentoAddress
        iceServers = ["turn:\(startCall.chatDataDto.turnAddress)?transport=udp", "turn:\(startCall.chatDataDto.turnAddress)?transport=tcp"] // "stun:46.32.6.188:3478"
        turnAddress = startCall.chatDataDto.turnAddress
        topicSend = startCall.clientDTO.topicSend
        topicReceive = startCall.clientDTO.topicReceive
        brokerAddressWeb = startCall.chatDataDto.brokerAddressWeb
        dataChannel = false
        customFrameCapturer = false
        userName = "mkhorrami"
        password = "mkh_123456"
        self.fileName = fileName
    }

    public var topicVideoSend: String? {
        guard let topicSend = topicSend else { return nil }
        return "Vi-\(topicSend)"
    }

    public var topicAudioSend: String? {
        guard let topicSend = topicSend else { return nil }
        return "Vo-\(topicSend)"
    }

    public var topicVideoReceive: String? {
        guard let topicReceive = topicReceive else { return nil }
        return "Vi-\(topicReceive)"
    }

    public var topicAudioReceive: String? {
        guard let topicReceive = topicReceive else { return nil }
        return "Vo-\(topicReceive)"
    }
}
