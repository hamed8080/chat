//
// WebRTCConfig.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatDTO
import ChatCore
import WebRTC

public struct WebRTCConfig {
    public let callConfig: CallConfig
    public let peerName: String
    public let turnAddress: [String]
    public let brokerAddress: [String]
    public let brokerAddressWeb: String
    public let topicSend: String?
    public let topicReceive: String?
    public let dataChannel: Bool
    public let customFrameCapturer: Bool
    public let userName: String?
    public let password: String?

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
        peerName = startCall.chatDataDto.kurentoAddress.first ?? ""
        turnAddress = startCall.chatDataDto.turnAddress
        topicSend = startCall.clientDTO.topicSend
        topicReceive = startCall.clientDTO.topicReceive
        brokerAddressWeb = startCall.chatDataDto.brokerAddressWeb.first ?? ""
        brokerAddress = startCall.chatDataDto.brokerAddress
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
    
    public var iceServers: [RTCIceServer] {
        turnAddress.compactMap({
            RTCIceServer(
                urlStrings: ["turn:\($0)?transport=udp", "turn:\($0)?transport=tcp"],
                username: userName!,
                credential: password!
            )
        })
    }
}
