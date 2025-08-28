//
// CallParticipantUserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import ChatModels
@preconcurrency import WebRTC

@ChatGlobalActor
open class CallParticipantUserRTC: Identifiable, Equatable {
    nonisolated public static func == (lhs: CallParticipantUserRTC, rhs: CallParticipantUserRTC) -> Bool {
        lhs.id == rhs.id
    }

    public nonisolated let id: Int
    public var callParticipant: CallParticipant
    public let audioRTC: AudioRTC
    public let videoRTC: VideoRTC

    public required init(chatDelegate: ChatDelegate?, myUserId: Int?, callParticipant: CallParticipant, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        self.id = callParticipant.userId ?? callParticipant.participant?.id ?? -1
        self.callParticipant = callParticipant
        let direction: RTCDirection = callParticipant.userId == myUserId ? .send : .receive
        audioRTC = AudioRTC(chatDelegate: chatDelegate, direction: direction, topic: callParticipant.topics.topicAudio, config: config, delegate: delegate)
        videoRTC = VideoRTC(renderer: nil, direction: direction, topic: callParticipant.topics.topicVideo, config: config, delegate: delegate)
    }

    public func addStreams() {
        if !isMe {
            audioRTC.addReceiveStream()
            audioRTC.monitorAudioLevelFor(callParticipant: callParticipant)
            videoRTC.addReceiveStream()
        }
    }

    public func createMediaSenderTracks(_ fileName: String? = nil) {
        if isMe {
            audioRTC.createMediaSenderTrack()
            videoRTC.createMediaSenderTrack(fileName)
            audioRTC.monitorAudioLevelFor(callParticipant: callParticipant)
        }
    }
    
    func getOfferSDP(video: Bool) async throws -> RTCSessionDescription {
        video ? try await videoRTC.getLocalSDPWithOffer() : try await audioRTC.getLocalSDPWithOffer()
    }
    
    public func toggleMute() {
        callParticipant.mute.toggle()
        audioRTC.setTrackEnable(!callParticipant.mute)
    }
    
    public func toggleCamera() {
        callParticipant.video?.toggle()
        videoRTC.setTrackEnable(callParticipant.video ?? false)
    }
    
    public func switchCameraPosition() {
        if isMe {
            videoRTC.switchCameraPosition()
        }
    }

    public func setRemoteIceCandidate(_ res: RemoteCandidateRes) {
        if isVideoTopic(topic: res.topic) {
            videoRTC.addIceToPeerConnection(res)
        } else {
            audioRTC.addIceToPeerConnection(res)
        }
    }

    public func setRemoteDescription(_ remoteSDP: RemoteSDPRes) {
        guard let topic = remoteSDP.topic else { return }
        if isVideoTopic(topic: topic) {
            videoRTC.setRemoteDescription(remoteSDP)
        } else {
            audioRTC.setRemoteDescription(remoteSDP)
        }
    }
    
    public func close() {
        audioRTC.close()
        videoRTC.close()
    }
}

// MARK: Utilities functions
extension CallParticipantUserRTC {
    public func peerConnectionForTopic(topic: String) -> RTCPeerConnection? {
        userRTC(topic: topic)?.pc
    }

    private func userRTC(topic: String) -> UserRTC? {
        topic == audioRTC.topic ? audioRTC : topic == videoRTC.topic ? videoRTC : nil
    }
    
    private func isVideoTopic(topic: String) -> Bool {
        topic.contains("Vi-")
    }
    
    private var isSender: Bool {
        audioRTC.direction == .send && videoRTC.direction == .send
    }
    
    public var isMe: Bool { isSender }
}
