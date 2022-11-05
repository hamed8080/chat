//
// WebRTCConfigOld.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct WebRTCConfigOld {
    public let peerName: String
    public let iceServers: [String]
    public let brokerAddress: String
    public let topicVideoSend: String
    public let topicVideoReceive: String
    public let topicAudioSend: String
    public let topicAudioReceive: String
    public let dataChannel: Bool
    public let customFrameCapturer: Bool
    public let userName: String?
    public let password: String?

    public let videoConfig: VideoConfig?

    public init(peerName: String,
                iceServers: [String],
                topicVideoSend: String,
                topicVideoReceive: String,
                topicAudioSend: String,
                topicAudioReceive: String,
                brokerAddress: String,
                dataChannel: Bool = false,
                customFrameCapturer: Bool = false,
                userName: String? = nil,
                password: String? = nil,
                videoConfig: VideoConfig? = nil)
    {
        self.peerName = peerName
        self.iceServers = iceServers
        self.topicVideoSend = topicVideoSend
        self.topicVideoReceive = topicVideoReceive
        self.topicAudioSend = topicAudioSend
        self.topicAudioReceive = topicAudioReceive
        self.brokerAddress = brokerAddress
        self.dataChannel = dataChannel
        self.customFrameCapturer = customFrameCapturer
        self.userName = userName
        self.password = password
        self.videoConfig = videoConfig
    }
}
