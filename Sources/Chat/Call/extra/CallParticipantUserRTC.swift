//
// CallParticipantUserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import ChatModels
@preconcurrency import WebRTC

public final class CallParticipantUserRTC: Identifiable, Equatable, @unchecked Sendable {
    nonisolated public static func == (lhs: CallParticipantUserRTC, rhs: CallParticipantUserRTC) -> Bool {
        lhs.id == rhs.id
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public nonisolated let id: Int
    public var callParticipant: CallParticipant
    public var topic: String
    public var iceQueue: [RTCIceCandidate] = []
    public var audioTrack: RTCAudioTrack?
    public var videoTrack: RTCVideoTrack?
    private var topicMids: [String: [String]] = [:]

    public var isFrontCamera: Bool = true
    public var isVideoTrackEnable: Bool { callParticipant.video ?? false }
    public var isSpeaking: Bool = false
    public var lastTimeSpeaking: Date?
    private weak var container: CallContainer?
    
    public init(callParticipant: CallParticipant, topic: String, container: CallContainer) {
        self.id = callParticipant.clientId ?? -1
        self.callParticipant = callParticipant
        self.topic = topic
        self.container = container
    }
    
    public func addMids(topic: String, mids: [String]) {
        topicMids[topic] = mids
    }
    
    public func removeMids(topic: String) {
        topicMids.removeValue(forKey: topic)
    }
    
    public func getMids(for topic: String) -> [String] {
        return topicMids[topic] ?? []
    }
    
    public func topic(for mid: String) -> String? {
        return topicMids.first(where: {$0.value.contains(where: {$0 == mid})})?.key
    }
    
    public func toggleMute() {
        callParticipant.mute.toggle()
        setTrackEnable(!callParticipant.mute)
    }
    
    public func toggleCamera() {
        callParticipant.video?.toggle()
        setTrackEnable(callParticipant.video ?? false)
    }
    
    public func close(videoStream: Bool) {
        if videoStream {
            
        } else {
            close()
        }
    }
    
    public func setTrackEnable(_ enable: Bool) {
        //        track?.isEnabled = enable
    }
    
    public func addReceiveStream(transciver: RTCRtpTransceiver?) {
        if let remoteTrack = transciver?.receiver.track {
            //            track = remoteTrack
            //            container.peerConection.add(remoteTrack, streamIds: [topic])
        }
    }
    
    public func removeVideoRenderer(_ renderer: RTCVideoRenderer) {
        //        (track as? RTCVideoTrack)?.remove(renderer)
    }

    public func switchCameraPosition() {
//        if isMe {
//            let result = (videoCapturer as? RTCCameraVideoCapturer)
//            let tuple = tuple
//            result?.stopCapture { [weak self] in
//                self?.isFrontCamera.toggle()
//                self?.startCaptureLocalVideo(tuple: tuple)
//            }
//        }
    }

    public func addReceiveStream() {
//        var error: NSError?
//        let transciver = pc.addTransceiver(of: .video)
//        transciver?.setDirection(.recvOnly, error: &error)
//        super.addReceiveStream(transciver: transciver)
//        if let renderer = renderer {
//            addVideoRenderer(renderer)
//        }
        
        //        var error: NSError?
        //        let transciver = pc.addTransceiver(of: .audio)
        //        transciver?.setDirection(.recvOnly, error: &error)
        //        super.addReceiveStream(transciver: transciver)
    }

    public func monitorAudioLevelFor(callParticipant: CallParticipant) {
//        speakingMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            Task { @ChatGlobalActor in
//                pc.statistics { report in
//                    for stat in report.statistics.values.filter({ $0.type == "track" }) {
//                        self.onSpeakingLevelChange(stat, callParticipant)
//                    }
//                }
//            }
//        }
    }

    public func onSpeakingLevelChange(_ stat: Dictionary<String, RTCStatistics>.Values.Element, _ callParticipant: CallParticipant) {
//        if (stat.values["audioLevel"] as? Double ?? .zero) > 0.01 {
//            participantStartSpeaking()
//            delegate?.chatEvent(event: .call(.callParticipantStartSpeaking(.init(result: callParticipant, typeCode: nil))))
//        } else if let lastSpeakingTime = lastTimeSpeaking, lastSpeakingTime.timeIntervalSince1970 + 3 < Date().timeIntervalSince1970 {
//            participantStopSpeaking()
//            delegate?.chatEvent(event: .call(.callParticipantStopSpeaking(.init(result: callParticipant, typeCode: nil))))
//        }
    }

    public func participantStartSpeaking() {
//        isSpeaking = true
//        lastTimeSpeaking = Date()
    }

    public func participantStopSpeaking() {
//        isSpeaking = false
//        lastTimeSpeaking = nil
    }

    public func close() {
//        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture()
//        speakingMonitorTimer?.invalidate()
//        speakingMonitorTimer = nil
    }
}

// MARK: Utilities functions
extension CallParticipantUserRTC {
//    public func peerConnectionForTopic(topic: String) -> RTCPeerConnection? {
//        userRTC(topic: topic)?.pc
//    }
//
//    private func userRTC(topic: String) -> UserRTC? {
//        topic == audioRTC.topic ? audioRTC : topic == videoRTC.topic ? videoRTC : nil
//    }
    
//    private func isVideoTopic(topic: String) -> Bool {
//        topic.contains("Vi-")
//    }
//    
//    private var isSender: Bool {
//        audioRTC.direction == .send && videoRTC.direction == .send
//    }
//    
//    public var isMe: Bool { isSender }
}
