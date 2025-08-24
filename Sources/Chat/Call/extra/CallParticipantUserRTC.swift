//
// CallParticipantUserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import ChatModels
import WebRTC

@ChatGlobalActor
open class CallParticipantUserRTC: CallParticipantUserRTCProtocol, Identifiable, Equatable {
    nonisolated public static func == (lhs: CallParticipantUserRTC, rhs: CallParticipantUserRTC) -> Bool {
        lhs.id == rhs.id
    }

    public let id: Int
    public var callParticipant: CallParticipant
    public var audioRTC: AudioRTC
    public var videoRTC: VideoRTC
    public var userId: Int?
    public var isMe: Bool { callParticipant.userId == userId }

    public required init(chatDelegate: ChatDelegate?, userId: Int?, callParticipant: CallParticipant, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        self.id = callParticipant.userId ?? callParticipant.participant?.id ?? -1
        self.userId = userId
        self.callParticipant = callParticipant
        let direction: RTCDirection = callParticipant.userId == userId ? .send : .receive
        audioRTC = AudioRTC(chatDelegate: chatDelegate, direction: direction, topic: callParticipant.topics.topicAudio, config: config, delegate: delegate)
        videoRTC = VideoRTC(direction: direction, topic: callParticipant.topics.topicVideo, config: config, delegate: delegate)
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

    public func uerRTC(topic: String) -> UserRTCProtocol? {
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

    func getAudioOffer(_ completion: ((String, RTCSessionDescription, String, Mediatype) -> Void)?) {
        audioRTC.getLocalSDPWithOffer { [weak self] rtcSession in
            guard let self = self else { return }
            completion?(self.isMe ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER", rtcSession, self.audioRTC.topic, .audio)
        }
    }

    func getVideoOffer(_ completion: ((String, RTCSessionDescription, String, Mediatype) -> Void)?) {
        videoRTC.getLocalSDPWithOffer { [weak self] rtcSession in
            guard let self = self else { return }
            completion?(self.isMe ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER", rtcSession, self.videoRTC.topic, .video)
        }
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
