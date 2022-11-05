//
// WebRTCClientNewLocalSignaling.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
import WebRTC

// MARK: - Pay attention, this class use many extensions inside a files not be here.

public class WebRTCClientNewLocalSignaling: NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    private var peerConnectionFactory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    private var delegate: WebRTCClientDelegate?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var videoCapturer: RTCVideoCapturer?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    private var isFrontCamera: Bool = true
    private var remoteVideoRenderer: RTCVideoRenderer?

    private var signalingClient: SignalingClient?

    private let mediaConstrains: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
                                                     kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue]

    private(set) var isConnected: Bool = false {
        didSet {
            if isConnected == true {
                setConnectedState()
            } else {
                setDisconnectedState()
            }
        }
    }

    public init(delegate: WebRTCClientDelegate? = nil) {
        self.delegate = delegate
        RTCInitializeSSL()

        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        super.init()

        let rtcConfig = RTCConfiguration()
        rtcConfig.sdpSemantics = .unifiedPlan
        rtcConfig.continualGatheringPolicy = .gatherContinually
        let iceServers = ["stun:stun.l.google.com:19302",
                          "stun:stun1.l.google.com:19302",
                          "stun:stun2.l.google.com:19302",
                          "stun:stun3.l.google.com:19302",
                          "stun:stun4.l.google.com:19302"]
        rtcConfig.iceServers = [RTCIceServer(urlStrings: iceServers)]
        let sendConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: mediaConstrains)

        peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: sendConstraints, delegate: nil)
        peerConnection?.delegate = self
        createMediaSenders()

        if #available(iOS 13.0, *) {
            let provider = NativeWebSocketProvider(url: URL(string: "ws://192.168.1.4:8080")!)
            signalingClient = SignalingClient(webSocketProvider: provider)
            signalingClient?.delegate = self
            signalingClient?.connect()
        } else {
            let provider = StarScreamWebSocketProvider(url: URL(string: "ws://192.168.1.4:8080")!)
            signalingClient = SignalingClient(webSocketProvider: provider)
            signalingClient?.delegate = self
            signalingClient?.connect()
        }
    }

    private func setConnectedState() {
        DispatchQueue.main.async {
            Chat.sharedInstance.logger?.log(title: "--- on connected ---")
            self.delegate?.didConnectWebRTC()
        }
    }

    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState() {
        DispatchQueue.main.async {
            self.isConnected = false
            Chat.sharedInstance.logger?.log(title: "--- on dis connected ---")
            self.peerConnection?.close()
            self.peerConnection = nil
            //			self.dataChannel = nil
            self.delegate?.didDisconnectWebRTC()
        }
    }

    /// Client can call this to dissconnect from peer.
    public func disconnect() {
        guard let peerConnection = peerConnection else { Chat.sharedInstance.logger?.log(title: "peer connection already is nil"); return }
        peerConnection.close()
    }

    public func getLocalSDPWithOffer(onSuccess: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection?.offer(for: constraints, completionHandler: { sdp, error in
            if let error = error {
                Chat.sharedInstance.logger?.log(title: "error make offer\(error.localizedDescription)")
                return
            }
            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in
                onSuccess(sdp)
            })
        })
    }

    public func sendOfferToPeer(_ sdp: RTCSessionDescription) {
        signalingClient?.send(sdp)
    }

    public func getAnswerSDP(onSuccess: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
        peerConnection?.answer(for: constraints, completionHandler: { sdp, error in
            if let error = error {
                Chat.sharedInstance.logger?.log(title: "error make offer\(error.localizedDescription)")
                return
            }

            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in
                onSuccess(sdp)
            })
        })
    }

    public func sendAnswerToPeer(_ sdp: RTCSessionDescription) {
        signalingClient?.send(sdp)
    }

    private func createMediaSenders() {
        let streamId = "stream"

        // Audio
        let audioTrack = createAudioTrack()
        peerConnection?.add(audioTrack, streamIds: [streamId])

        // Video
        let videoTrack = createVideoTrack()
        localVideoTrack = videoTrack
        peerConnection?.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = peerConnection?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
    }

    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = peerConnectionFactory.videoSource()

        #if targetEnvironment(simulator)
            videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
            videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif

        let videoTrack = peerConnectionFactory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }

    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = peerConnectionFactory.audioSource(with: audioConstrains)
        let audioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }

    public func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer,
              let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }),
              let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { f1, f2 -> Bool in
                  let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                  let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                  return width1 < width2
              }).last, // TODO: - must chose resulation from configVideo
              let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
        else { return }
        Chat.sharedInstance.logger?.log(title: "selected width is\(CMVideoFormatDescriptionGetDimensions(format.formatDescription).width)")
        capturer.startCapture(with: frontCamera, format: format, fps: Int(maxFrameRate))
        localVideoTrack?.add(renderer)
    }

    public func switchCameraPosition(renderer: RTCVideoRenderer) {
        if let capturer = videoCapturer as? RTCCameraVideoCapturer {
            capturer.stopCapture {
                self.isFrontCamera.toggle()
                self.startCaptureLocalVideo(renderer: renderer)
            }
        }
    }

    public func renderRemoteVideo(_ renderer: RTCVideoRenderer) {
        remoteVideoTrack?.add(renderer)
    }

    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        peerConnection?.setRemoteDescription(remoteSdp, completionHandler: completion)
    }

    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> Void) {
        peerConnection?.add(remoteCandidate, completionHandler: completion)
    }
}

// MARK: - RTCPeerConnectionDelegate

public extension WebRTCClientNewLocalSignaling {
    func peerConnection(_: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        Chat.sharedInstance.logger?.log(title: "peerConnection signaling state changed: \(String(describing: stateChanged.stringValue))")
    }

    func peerConnection(_: RTCPeerConnection, didAdd _: RTCMediaStream) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did add stream")
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_: RTCPeerConnection) {
        Chat.sharedInstance.logger?.log(title: "peerConnection should negotiate")
    }

    func peerConnection(_: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        Chat.sharedInstance.logger?.log(title: "peerConnection new connection state: \(String(describing: newState.stringValue))")
        switch newState {
        case .connected, .completed:
            if !isConnected {
                isConnected.toggle()
            }
        default:
            if isConnected {
                isConnected.toggle()
            }
        }
        DispatchQueue.main.async {
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
        }
    }

    func peerConnection(_: RTCPeerConnection, didChange _: RTCIceGatheringState) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did change new state")
    }

    func peerConnection(_: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did generate candidate")
        signalingClient?.send(candidate)
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did remove candidate(s)")
    }

    func peerConnection(_: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did open data channel \(dataChannel)")
        remoteDataChannel = dataChannel
    }
}

// MARK: - RTCDataChannelDelegate

public extension WebRTCClientNewLocalSignaling {
    func dataChannel(_: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            if buffer.isBinary {
                self.delegate?.didReceiveData(data: buffer.data)
            } else {
                self.delegate?.didReceiveMessage(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
            }
        }
    }

    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        Chat.sharedInstance.logger?.log(title: "data channel did change state")
        switch dataChannel.readyState {
        case .closed:
            Chat.sharedInstance.logger?.log(title: "closed")
        case .closing:
            Chat.sharedInstance.logger?.log(title: "closing")
        case .connecting:
            Chat.sharedInstance.logger?.log(title: "connecting")
        case .open:
            Chat.sharedInstance.logger?.log(title: "open")
        @unknown default:
            fatalError()
        }
    }
}

extension WebRTCClientNewLocalSignaling: SignalingClientDelegate {
    func signalClientDidConnect(_: SignalingClient) {
        setConnectedState()
    }

    func signalClientDidDisconnect(_: SignalingClient) {
        setDisconnectedState()
    }

    func signalClient(_: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        set(remoteSdp: sdp) { _ in
        }
    }

    func signalClient(_: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        set(remoteCandidate: candidate) { _ in
        }
    }

    func receiveMeassge(data _: Data) {}
}
