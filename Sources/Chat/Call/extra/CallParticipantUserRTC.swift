//
// CallParticipantUserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import ChatModels
import WebRTC

@ChatGlobalActor
open class CallParticipantUserRTC: Identifiable, Equatable {
    nonisolated public static func == (lhs: CallParticipantUserRTC, rhs: CallParticipantUserRTC) -> Bool {
        lhs.id == rhs.id
    }

    public let id: Int
    public var callParticipant: CallParticipant
    public let audioRTC: AudioRTC
    public let videoRTC: VideoRTC
    public var userId: Int?
    public var isMe: Bool { callParticipant.userId == userId }

    public required init(chatDelegate: ChatDelegate?, userId: Int?, callParticipant: CallParticipant, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        self.id = callParticipant.userId ?? callParticipant.participant?.id ?? -1
        self.userId = userId
        self.callParticipant = callParticipant
        let direction: RTCDirection = callParticipant.userId == userId ? .send : .receive
        audioRTC = AudioRTC(chatDelegate: chatDelegate, direction: direction, topic: callParticipant.topics.topicAudio, config: config, delegate: delegate)
        videoRTC = VideoRTC(renderer: nil, direction: direction, topic: callParticipant.topics.topicVideo, config: config, delegate: delegate)
    }

    public func peerConnectionForTopic(topic: String) -> RTCPeerConnection? {
        if audioRTC.topic == topic {
            return audioRTC.pc
        } else if videoRTC.topic == topic {
            return videoRTC.pc
        } else {
            return nil
        }
    }

    public func uerRTC(topic: String) -> UserRTC? {
        if audioRTC.topic == topic {
            return audioRTC
        } else if videoRTC.topic == topic {
            return videoRTC
        } else {
            return nil
        }
    }

    public func addStreams() {
        if !isMe {
            audioRTC.addReceiveStream()
            audioRTC.monitorAudioLevelFor(callParticipant: callParticipant)
            videoRTC.addReceiveStream()
        }
    }
   
    func getOfferSDP(video: Bool) async throws -> RTCSessionDescription {
        video ? try await videoRTC.getLocalSDPWithOffer() : try await audioRTC.getLocalSDPWithOffer()
    }

    public func createMediaSenderTracks(_ fileName: String? = nil) {
        if isMe {
            audioRTC.createMediaSenderTrack()
            videoRTC.createMediaSenderTrack(fileName)
            audioRTC.monitorAudioLevelFor(callParticipant: callParticipant)
        }
    }

    public func toggleMute() {
        if isMe {
            callParticipant.mute.toggle()
            audioRTC.setTrackEnable(!callParticipant.mute)
        }
    }

    public func toggleCamera() {
        if isMe {
            callParticipant.video?.toggle()
            videoRTC.setTrackEnable(callParticipant.video ?? false)
        }
    }

    public func addIceCandidate(_ candidate: RemoteCandidateRes) {
        if isVideoTopic(topic: candidate.topic) {
            videoRTC.addIceToPeerConnection(candidate)
        } else {
            audioRTC.addIceToPeerConnection(candidate)
        }
    }

    public func setRemoteDescription(_ remoteSDP: RemoteSDPRes) {
        print("recieve remote SDP for user:\(callParticipant.participant?.name ?? "") topic:\(remoteSDP.topic) sdp:\(remoteSDP)")
        if isVideoTopic(topic: remoteSDP.topic) {
            videoRTC.setRemoteDescription(remoteSDP)
        } else {
            audioRTC.setRemoteDescription(remoteSDP)
        }
    }

    func isVideoTopic(topic: String) -> Bool {
        topic.contains("Vi-")
    }

    public func switchCameraPosition() {
        if isMe {
            videoRTC.switchCameraPosition()
        }
    }

    public func close() {
        audioRTC.close()
        videoRTC.close()
    }
}

extension RTCSessionDescription: @unchecked Sendable {}
