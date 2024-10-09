//
// UserRTC.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC
import ChatCore
import Chat
import ChatModels

public enum RTCDirection {
    case send
    case receive
    case inactive
}

/// This struct use to save state of a particular call participant which can be a single video or audio
/// user for a call participant because in this system for each call participant we have two user and peerconnection one for audio and one for video or in the future data.
///
public protocol UserRTCProtocol {
    var id: String { get }
    var pf: RTCPeerConnectionFactory? { get set }
    var pc: RTCPeerConnection? { get set }
    var direction: RTCDirection { get set }
    var topic: String { get set }
    var iceQueue: [RTCIceCandidate] { get set }
    var iceTimer: Timer? { get set }
    var constraints: [String: String] { get set }
    var track: RTCMediaStreamTrack? { get set }
    func getLocalSDPWithOffer(onSuccess: @escaping (RTCSessionDescription) -> Void)
    func setTrackEnable(_ enable: Bool)
    func addReceiveStream(transciver: RTCRtpTransceiver?)
    func addIceToPeerConnection(_ candidate: RemoteCandidateRes)
    func setRemoteIceOnMainThread(_ rtcIce: RTCIceCandidate)
    func close()
}

public protocol AudioRTCProtocol: UserRTCProtocol {
    var isSpeaking: Bool { get set }
    var lastTimeSpeaking: Date? { get set }
    var speakingMonitorTimer: Timer? { get set }
    var delegate: ChatDelegate? { get set }
    func participantStartSpeaking()
    func participantStopSpeaking()
    func monitorAudioLevelFor(callParticipant: CallParticipant)
    func onSpeakingLevelChange(_ stat: Dictionary<String, RTCStatistics>.Values.Element, _ callParticipant: CallParticipant)
    func addReceiveStream()
    func createMediaSenderTrack()
}

public protocol VideoRTCProtocol: UserRTCProtocol {
    var renderer: RTCVideoRenderer? { get set }
    var videoCapturer: RTCVideoCapturer? { get }
    var isFrontCamera: Bool { get }
    func addVideoRenderer(_ renderer: RTCVideoRenderer)
    func removeVideoRenderer(_ renderer: RTCVideoRenderer)
    func getCameraFormat() -> AVCaptureDevice.Format?
    func switchCameraPosition()
    func addReceiveStream()
    func createMediaSenderTrack(_ fileName: String?)
}

public class UserRTC: UserRTCProtocol, Hashable, Identifiable {
    public var id: String { topic }
    public var pf: RTCPeerConnectionFactory?
    public var pc: RTCPeerConnection?
    public var direction: RTCDirection
    public var topic: String
    public var iceQueue: [RTCIceCandidate] = []
    public var iceTimer: Timer?
    public var track: RTCMediaStreamTrack?
    public var constraints: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse, kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse]

    public static func == (lhs: UserRTC, rhs: UserRTC) -> Bool {
        lhs.topic == rhs.topic
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(topic)
    }

    init(direction: RTCDirection, topic: String, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate, customConstraint: [String: String], videoDecoder: RTCVideoDecoderFactory? = nil, videoEncoder: RTCVideoEncoderFactory? = nil) {
        self.direction = direction
        self.topic = topic
        pf = RTCPeerConnectionFactory(encoderFactory: videoEncoder, decoderFactory: videoDecoder)
        let op = RTCPeerConnectionFactoryOptions()
        // op.disableEncryption = true
        pf?.setOptions(op)
        var rtcConfig: RTCConfiguration {
            let rtcConfig = RTCConfiguration()
            rtcConfig.sdpSemantics = .unifiedPlan
            rtcConfig.iceTransportPolicy = .relay
            rtcConfig.continualGatheringPolicy = .gatherContinually
            rtcConfig.iceServers = [RTCIceServer(urlStrings: config.iceServers, username: config.userName!, credential: config.password!)]
            return rtcConfig
        }
        customConstraint.forEach { key, value in
            constraints[key] = value
        }
        if let peerConnection = pf?.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]), delegate: nil) {
            pc = peerConnection
            pc?.delegate = delegate
        }
    }

    public func setTrackEnable(_ enable: Bool) {
        track?.isEnabled = enable
    }

    public func addReceiveStream(transciver: RTCRtpTransceiver?) {
        if let remoteTrack = transciver?.receiver.track {
            track = remoteTrack
            pc?.add(remoteTrack, streamIds: [topic])
        }
    }

    public func getLocalSDPWithOffer(onSuccess: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueFalse])
        pc?.offer(for: constraints) { [weak self] sdp, _ in
            guard let sdp = sdp else { return }
            self?.pc?.setLocalDescription(sdp) { _ in
                onSuccess(sdp)
            }
        }
    }

    /// check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    public func addIceToPeerConnection(_ candidate: RemoteCandidateRes) {
        let rtcIce = candidate.rtcIceCandidate
        if pc?.remoteDescription != nil {
            setRemoteIceOnMainThread(rtcIce)
        } else {
            iceQueue.append(rtcIce)
            iceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                if self?.pc?.remoteDescription != nil {
                    self?.setRemoteIceOnMainThread(rtcIce)
                    self?.iceQueue.removeAll(where: { $0 == rtcIce })
                    print("ICE added to \(self?.topic ?? "") from Queue and remaining in Queue is: \(self?.iceQueue.count ?? 0)")
                    timer.invalidate()
                }
            }
        }
    }

    public func setRemoteIceOnMainThread(_ rtcIce: RTCIceCandidate) {
        DispatchQueue.main.async { [weak self] in
            self?.pc?.add(rtcIce) { error in
                if let error = error {
                    print("error on add ICE Candidate with ICE:\(rtcIce.sdp) \(error)")
                }
            }
        }
    }

    func setRemoteDescription(_ remoteSDP: RemoteSDPRes) {
        DispatchQueue.main.async { [weak self] in
            self?.pc?.setRemoteDescription(remoteSDP.rtcSDP) { error in
                if let error = error {
                    print("error in setRemoteDescroptoin with for topic:\(remoteSDP.topic) sdp: \(remoteSDP.rtcSDP) with error: \(error)")
                }
            }
        }
    }

    public func close() {
        pc?.close()
    }
}

public class AudioRTC: UserRTC, AudioRTCProtocol {
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
            guard let audioSource = pf?.audioSource(with: audioConstrains) else { return }
            if let track = pf?.audioTrack(with: audioSource, trackId: "audio0") {
                self.track = track
                pc?.add(track, streamIds: [topic])
            }
        }
    }

    public func addReceiveStream() {
        var error: NSError?
        let transciver = pc?.addTransceiver(of: .audio)
        transciver?.setDirection(.recvOnly, error: &error)
        super.addReceiveStream(transciver: transciver)
    }

    public func monitorAudioLevelFor(callParticipant: CallParticipant) {
        speakingMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.pc?.statistics { report in
                report.statistics.values.filter { $0.type == "track" }.forEach { stat in
                    DispatchQueue.main.async {
                        self?.onSpeakingLevelChange(stat, callParticipant)
                    }
                }
            }
        }
    }

    public func onSpeakingLevelChange(_ stat: Dictionary<String, RTCStatistics>.Values.Element, _ callParticipant: CallParticipant) {
        if (stat.values["audioLevel"] as? Double ?? .zero) > 0.01 {
            participantStartSpeaking()
            delegate?.chatEvent(event: .call(.callParticipantStartSpeaking(.init(result: callParticipant))))
        } else if let lastSpeakingTime = lastTimeSpeaking, lastSpeakingTime.timeIntervalSince1970 + 3 < Date().timeIntervalSince1970 {
            participantStopSpeaking()
            delegate?.chatEvent(event: .call(.callParticipantStopSpeaking(.init(result: callParticipant))))
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

public class VideoRTC: UserRTC, VideoRTCProtocol {
    public var renderer: RTCVideoRenderer?
    public var videoCapturer: RTCVideoCapturer?
    public var isFrontCamera: Bool = true
    public var isVideoTrackEnable: Bool { track?.isEnabled ?? false }
    public let config: WebRTCConfig

    init(direction: RTCDirection, topic: String, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate) {
        self.config = config
        renderer = TARGET_OS_SIMULATOR != 0 ? RTCEAGLVideoView(frame: .zero) : RTCMTLVideoView(frame: .zero)
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
            guard let videoSource = pf?.videoSource() else { return }
            if TARGET_OS_SIMULATOR != 0 {
                videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
            } else {
                videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
            }
            if let track = pf?.videoTrack(with: videoSource, trackId: "video0") {
                self.track = track
                pc?.add(track, streamIds: [topic])
                startCaptureLocalVideo(fileName)
            }
        }
    }

    private func startCaptureLocalVideo(_ fileName: String? = nil) {
        if let videoCapturer = videoCapturer as? RTCCameraVideoCapturer,
           let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }),
           let format = getCameraFormat()
        {
            DispatchQueue.global(qos: .background).async {
                videoCapturer.startCapture(with: selectedCamera, format: format, fps: self.config.callConfig.targetFPS)
            }
        } else if let videoCapturer = videoCapturer as? RTCFileVideoCapturer {
            videoCapturer.startCapturing(fromFileNamed: fileName ?? "") { _ in }
        }
        if let renderer = renderer {
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
        result?.stopCapture { [weak self] in
            self?.isFrontCamera.toggle()
            self?.startCaptureLocalVideo()
        }
    }

    public func addReceiveStream() {
        var error: NSError?
        let transciver = pc?.addTransceiver(of: .video)
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
