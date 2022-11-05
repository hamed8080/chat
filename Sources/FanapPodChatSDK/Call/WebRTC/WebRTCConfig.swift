//
// WebRTCConfig.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct VideoConfig {
    public let width: Int
    public let height: Int
    public let fps: Int
    public let localVideoViewFrame: CGRect?
    public let remoteVideoViewFrame: CGRect?

    public init(width: Int = 640, height: Int = 640 * 16 / 9, fps: Int = 30, localVideoViewFrame: CGRect, remoteVideoViewFrame: CGRect) {
        self.width = width
        self.height = height
        self.fps = fps
        self.localVideoViewFrame = localVideoViewFrame
        self.remoteVideoViewFrame = remoteVideoViewFrame
    }
}

public struct WebRTCConfig {
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

    /// File for simulator
    public let fileName: String?

    public let videoConfig: VideoConfig?

    public init(peerName: String,
                iceServers: [String],
                turnAddress: String,
                topicSend: String?,
                topicReceive: String?,
                brokerAddressWeb: String,
                dataChannel: Bool = false,
                customFrameCapturer: Bool = false,
                userName: String? = nil,
                password: String? = nil,
                videoConfig: VideoConfig? = nil,
                fileName: String? = nil)
    {
        self.peerName = peerName
        self.iceServers = iceServers
        self.turnAddress = turnAddress
        self.topicSend = topicSend
        self.topicReceive = topicReceive
        self.brokerAddressWeb = brokerAddressWeb
        self.dataChannel = dataChannel
        self.customFrameCapturer = customFrameCapturer
        self.userName = userName
        self.password = password
        self.videoConfig = videoConfig
        self.fileName = fileName
    }

    var firstBorokerAddressWeb: String {
        if let firstBrokerAddressWeb = brokerAddressWeb.split(separator: ",").first {
            return String(firstBrokerAddressWeb)
        } else {
            return ""
        }
    }

    public init(startCall: StartCall, isSendVideoEnabled _: Bool, fileName: String? = nil) {
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
        videoConfig = nil
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
