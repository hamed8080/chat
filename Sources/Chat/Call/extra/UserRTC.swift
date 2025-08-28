//
// UserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
@preconcurrency import WebRTC
import ChatCore
import ChatModels

public enum RTCDirection {
    case send
    case receive
    case inactive
}

public class UserRTC: Hashable, Identifiable {
    nonisolated public let id: String
    public var pf: RTCPeerConnectionFactory
    public var pc: RTCPeerConnection
    public var direction: RTCDirection
    public var topic: String
    public var iceQueue: [RTCIceCandidate] = []
    public var iceTimer: Timer?
    public var track: RTCMediaStreamTrack?
    public var constraints: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse, kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse]

    nonisolated public static func == (lhs: UserRTC, rhs: UserRTC) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(direction: RTCDirection, topic: String, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate, customConstraint: [String: String], videoDecoder: RTCVideoDecoderFactory? = nil, videoEncoder: RTCVideoEncoderFactory? = nil) {
        self.id = topic
        self.direction = direction
        self.topic = topic
        pf = RTCPeerConnectionFactory(encoderFactory: videoEncoder, decoderFactory: videoDecoder)
        let op = RTCPeerConnectionFactoryOptions()
        // op.disableEncryption = true
        pf.setOptions(op)
        var rtcConfig: RTCConfiguration {
            let rtcConfig = RTCConfiguration()
            rtcConfig.sdpSemantics = .unifiedPlan
            rtcConfig.iceTransportPolicy = .relay
            rtcConfig.continualGatheringPolicy = .gatherContinually
            rtcConfig.iceServers = [RTCIceServer(urlStrings: config.iceServers, username: config.userName!, credential: config.password!)]
            return rtcConfig
        }
        guard let peerConnection = pf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]), delegate: nil)
        else { fatalError("failed to init UserRTC") }
        
        pc = peerConnection
        pc.delegate = delegate
        
        customConstraint.forEach { key, value in
            constraints[key] = value
        }
    }

    public func setTrackEnable(_ enable: Bool) {
        track?.isEnabled = enable
    }

    public func addReceiveStream(transciver: RTCRtpTransceiver?) {
        if let remoteTrack = transciver?.receiver.track {
            track = remoteTrack
            pc.add(remoteTrack, streamIds: [topic])
        }
    }

    public func getLocalSDPWithOffer() async throws -> RTCSessionDescription {
        let constraints = RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueFalse])
        let sdp = try await pc.offer(for: constraints)
        let _ = try await pc.setLocalDescription(sdp)
        return sdp
    }

    /// check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    public func addIceToPeerConnection(_ candidate: RemoteCandidateRes) {
        let rtcIce = candidate.rtcIceCandidate
        if pc.remoteDescription != nil {
            setRemoteIce(rtcIce)
        } else {
            iceQueue.append(rtcIce)
            iceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//                Task { @ChatGlobalActor in
//                    if self?.pc?.remoteDescription != nil {
//                        self?.setRemoteIce(rtcIce)
//                        self?.iceQueue.removeAll(where: { $0 == rtcIce })
//                        print("ICE added to \(self?.topic ?? "") from Queue and remaining in Queue is: \(self?.iceQueue.count ?? 0)")
//                        timer.invalidate()
//                    }
//                }
            }
        }
    }
    
    public func setRemoteIce(_ rtcIce: RTCIceCandidate) {
        pc.add(rtcIce) { error in
            if let error = error {
                print("error on add ICE Candidate with ICE:\(rtcIce.sdp) \(error)")
            }
        }
    }

    func setRemoteDescription(_ remoteSDP: RemoteSDPRes) {
        guard let sdp = remoteSDP.rtcSDP else { return }
        pc.setRemoteDescription(sdp) { error in
            if let error = error {
                print("error in setRemoteDescroptoin with for topic:\(remoteSDP.topic) sdp: \(remoteSDP.rtcSDP) with error: \(error)")
            }
        }
    }

    public func close() {
        pc.close()
    }
}
 
public class AudioRTC: UserRTC, @unchecked Sendable {
    public var isSpeaking: Bool = false
    public var lastTimeSpeaking: Date?
    public var speakingMonitorTimer: Timer?
    public weak var delegate: ChatDelegate?

    init(chatDelegate: ChatDelegate?, direction: RTCDirection, topic: String, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        let custom: [String: String] = direction == .receive ? [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue] : [:]
        super.init(direction: direction, topic: topic, config: config, delegate: delegate, customConstraint: custom)
        self.delegate = chatDelegate
    }

    public func createMediaSenderTrack() {
        if track == nil {
            let audioConstrains = RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
            let audioSource = pf.audioSource(with: audioConstrains)
            let track = pf.audioTrack(with: audioSource, trackId: "audio0")
            self.track = track
            pc.add(track, streamIds: [topic])
        }
    }

    public func addReceiveStream() {
        var error: NSError?
        let transciver = pc.addTransceiver(of: .audio)
        transciver?.setDirection(.recvOnly, error: &error)
        super.addReceiveStream(transciver: transciver)
    }

    public func monitorAudioLevelFor(callParticipant: CallParticipant) {
        speakingMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @ChatGlobalActor in
                pc.statistics { report in
                    for stat in report.statistics.values.filter({ $0.type == "track" }) {
                        self.onSpeakingLevelChange(stat, callParticipant)
                    }
                }
            }
        }
    }

    public func onSpeakingLevelChange(_ stat: Dictionary<String, RTCStatistics>.Values.Element, _ callParticipant: CallParticipant) {
        if (stat.values["audioLevel"] as? Double ?? .zero) > 0.01 {
            participantStartSpeaking()
            delegate?.chatEvent(event: .call(.callParticipantStartSpeaking(.init(result: callParticipant, typeCode: nil))))
        } else if let lastSpeakingTime = lastTimeSpeaking, lastSpeakingTime.timeIntervalSince1970 + 3 < Date().timeIntervalSince1970 {
            participantStopSpeaking()
            delegate?.chatEvent(event: .call(.callParticipantStopSpeaking(.init(result: callParticipant, typeCode: nil))))
        }
    }

    public func participantStartSpeaking() {
        isSpeaking = true
        lastTimeSpeaking = Date()
    }

    public func participantStopSpeaking() {
        isSpeaking = false
        lastTimeSpeaking = nil
    }

    override public func close() {
        super.close()
        speakingMonitorTimer?.invalidate()
        speakingMonitorTimer = nil
    }
}

public class VideoRTC: UserRTC, @unchecked Sendable {
    public var renderer: RTCVideoRenderer?
    public var videoCapturer: RTCVideoCapturer?
    public var isFrontCamera: Bool = true
    public var isVideoTrackEnable: Bool { track?.isEnabled ?? false }
    public let config: WebRTCConfig

    init(renderer: RTCVideoRenderer?, direction: RTCDirection, topic: String, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        self.config = config
        self.renderer = renderer
        let custom: [String: String] = direction == .receive ? [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue] : [:]
        super.init(direction: direction, topic: topic, config: config, delegate: delegate, customConstraint: custom, videoDecoder: RTCDefaultVideoDecoderFactory.default, videoEncoder: RTCDefaultVideoEncoderFactory.default)
    }

    public func addVideoRenderer(_ renderer: RTCVideoRenderer) {
        (track as? RTCVideoTrack)?.add(renderer)
    }

    public func removeVideoRenderer(_ renderer: RTCVideoRenderer) {
        (track as? RTCVideoTrack)?.remove(renderer)
    }

    public func createMediaSenderTrack(_ fileName: String? = nil) {
        if track == nil {
            let videoSource = pf.videoSource()
            if TARGET_OS_SIMULATOR != 0 {
                videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
            } else {
                videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
            }
            
            let track = pf.videoTrack(with: videoSource, trackId: "video0")
            self.track = track
            pc.add(track, streamIds: [topic])
            let tuple = tuple
            startCaptureLocalVideo(fileName, tuple: tuple)
        }
    }
    
    typealias TupleType = (vid: RTCVideoCapturer?, fps: Int, isFrontCamera: Bool, renderer: RTCVideoRenderer?, format: AVCaptureDevice.Format?)
    private var tuple: TupleType {
        let vid = videoCapturer
        let fps = self.config.callConfig.targetFPS
        let isFrontCamera = isFrontCamera
        let renderer = renderer
        let format = getCameraFormat()
        return (vid, fps, isFrontCamera, renderer, format)
    }
    
    private func startCaptureLocalVideo(_ fileName: String? = nil, tuple: TupleType) {
        if let videoCapturer = tuple.vid as? RTCCameraVideoCapturer,
           let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (tuple.isFrontCamera ? .front : .back) }),
           let format = tuple.format
        {
            DispatchQueue.global(qos: .background).async {
                videoCapturer.startCapture(with: selectedCamera, format: format, fps: tuple.fps)
            }
        } else if let videoCapturer = tuple.vid as? RTCFileVideoCapturer, let fileName = fileName {
            videoCapturer.startCapturing(fromFileNamed: fileName) { _ in }
        }
        if let renderer = tuple.renderer {
            addVideoRenderer(renderer)
        }
    }

    public func getCameraFormat() -> AVCaptureDevice.Format? {
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }) else { return nil }
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last { format in
            let maxFrameRate = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate <= Float64(config.callConfig.targetFPS) })?.maxFrameRate ?? Float64(config.callConfig.targetFPS)
            let targetFPS = Int(maxFrameRate)
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            return dimensions.width == config.callConfig.targetVideoWidth && dimensions.height == config.callConfig.targetVideoHeight && Int(maxFrameRate) <= targetFPS
        }
        return format
    }

    public func switchCameraPosition() {
        let result = (videoCapturer as? RTCCameraVideoCapturer)
        let tuple = tuple
        result?.stopCapture { [weak self] in
            self?.isFrontCamera.toggle()
            self?.startCaptureLocalVideo(tuple: tuple)
        }
    }

    public func addReceiveStream() {
        var error: NSError?
        let transciver = pc.addTransceiver(of: .video)
        transciver?.setDirection(.recvOnly, error: &error)
        super.addReceiveStream(transciver: transciver)
        if let renderer = renderer {
            addVideoRenderer(renderer)
        }
    }

    override public func close() {
        super.close()
        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture()
    }
}
