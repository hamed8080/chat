//
// UserRCT.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import WebRTC

public enum RTCDirection {
    case send
    case receive
    case inactive
}

/// This struct use to save state of a particular call participant which can be a single video or audio
/// user for a call participant because in this system for each call participant we have two user and peerconnection one for audio and one for video or in the future data.
public struct UserRCT: Hashable {
    public static func == (lhs: UserRCT, rhs: UserRCT) -> Bool {
        lhs.topic == rhs.topic
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(topic)
    }

    public var topic: String
    public var direction: RTCDirection
    public var pf: RTCPeerConnectionFactory?
    public var pc: RTCPeerConnection?
    public var renderer: RTCVideoRenderer?
    public var videoTrack: RTCVideoTrack?
    private(set) var audioTrack: RTCAudioTrack?
    public private(set) var callParticipant: CallParticipant?
    public var dataChannel: RTCDataChannel?
    public var isSpeaking: Bool = false
    public var lastTimeSpeaking: Date?

    mutating func setVideoTrack(_ videoTrack: RTCVideoTrack?) {
        self.videoTrack = videoTrack
    }

    mutating func setAudioTrack(_ audioTrack: RTCAudioTrack?) {
        self.audioTrack = audioTrack
    }

    public var constraints: [String: String] {
        var const: [String: String] = [:]
        let videoKey = kRTCMediaConstraintsOfferToReceiveVideo
        let audioKey = kRTCMediaConstraintsOfferToReceiveAudio
        let trueValue = kRTCMediaConstraintsValueTrue
        let falseValue = kRTCMediaConstraintsValueFalse

        const[videoKey] = falseValue
        const[audioKey] = falseValue
        if direction == .receive {
            if isVideoTopic {
                const[videoKey] = trueValue
            } else {
                const[audioKey] = trueValue
            }
        }
        return const
    }

    mutating func setPeerFactory(_ pf: RTCPeerConnectionFactory) {
        self.pf = pf
    }

    mutating func setPeerConnection(_ pc: RTCPeerConnection) {
        self.pc = pc
    }

    public var isVideoTopic: Bool {
        topic.contains("Vi-")
    }

    public var isAudioTopic: Bool {
        topic.contains("Vo-")
    }

    public var rawTopicName: String {
        topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
    }

    mutating func setUsetIsSpeaking() {
        isSpeaking = true
        lastTimeSpeaking = Date()
    }

    mutating func setUsetStoppedSpeaking() {
        isSpeaking = false
        lastTimeSpeaking = nil
    }

    private mutating func setVideoTrack(enable: Bool) {
        videoTrack?.isEnabled = enable
    }

    private mutating func setAudioTrack(enable: Bool) {
        audioTrack?.isEnabled = enable
    }

    public var isMute: Bool {
        callParticipant?.mute ?? true
    }

    public var isVideoOn: Bool {
        callParticipant?.video ?? false
    }

    public var isVideoTrackEnable: Bool {
        videoTrack?.isEnabled ?? false
    }

    public var isAudioTrackEnable: Bool {
        audioTrack?.isEnabled ?? false
    }

    public mutating func setCallParticipant(_ callParticipant: CallParticipant?) {
        self.callParticipant = callParticipant
    }

    public mutating func setVideo(on: Bool) {
        setVideoTrack(enable: on)
        callParticipant?.video = on
    }

    public mutating func setMute(mute: Bool) {
        setAudioTrack(enable: !mute)
        callParticipant?.mute = mute
    }
}
