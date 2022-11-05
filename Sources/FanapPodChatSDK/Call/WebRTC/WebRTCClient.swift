//
// WebRTCClient.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
import WebRTC

public protocol WebRTCClientDelegate {
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
    func didReceiveData(data: Data)
    func didReceiveMessage(message: String)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.

public class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    static var instance: WebRTCClient? // for call methods when new message arrive from server

    private var peerConnectionFactory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    private var config: WebRTCConfigOld
    private var delegate: WebRTCClientDelegate?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var videoCapturer: RTCVideoCapturer?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    private var isFrontCamera: Bool = true
    private var remoteVideoRenderer: RTCVideoRenderer?
//    private let mediaConstrains       :[String:String]       = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
//                                                                kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]

    private let mediaConstrains: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
                                                     kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse]

    private(set) var isConnected: Bool = false {
        didSet {
            if isConnected == true {
                setConnectedState()
            } else {
                setDisconnectedState()
            }
        }
    }

    public init(config: WebRTCConfigOld, delegate: WebRTCClientDelegate? = nil) {
        self.delegate = delegate
        self.config = config
        RTCInitializeSSL()
        peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default, decoderFactory: RTCDefaultVideoDecoderFactory.default)
        super.init()

        let rtcConfig = RTCConfiguration()
        rtcConfig.sdpSemantics = .unifiedPlan
        rtcConfig.continualGatheringPolicy = .gatherContinually
        rtcConfig.iceServers = [RTCIceServer(urlStrings: config.iceServers, username: config.userName, credential: config.password)]
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)

        peerConnection = peerConnectionFactory.peerConnection(with: rtcConfig, constraints: constraints, delegate: nil)
        createMediaSenders()
        peerConnection?.delegate = self
        createSession()
        WebRTCClient.instance = self
    }

    private func createSession() {
        let session = CreateSessionReq(turnAddress: "", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token ?? "")
        if let data = try? JSONEncoder().encode(session) {
            send(data)
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

    public func sendMessage(_ message: String) {
        sendData(message.data(using: .utf8)!, isBinary: false)
    }

    /// Called when connction state change in RTCPeerConnectionDelegate.
    /// - Parameters:
    ///   - data: data to send to peer
    ///   - isBinary: Indicate data is string(UTF-8) or not if you pass true means data in not string and its a stream.
    public func sendData(_ data: Data, isBinary: Bool = true) {
        guard let remoteDataChannel = remoteDataChannel else { Chat.sharedInstance.logger?.log(title: "remote data channel is nil"); return }
        remoteDataChannel.sendData(data, isBinary: isBinary)
    }

    /// Client can call this to dissconnect from peer.
    public func disconnect() {
        guard let peerConnection = peerConnection else { Chat.sharedInstance.logger?.log(title: "peer connection already is nil"); return }
        peerConnection.close()
    }

    public func getLocalSDPWithOffer(isSend _: Bool, onSuccess: @escaping (RTCSessionDescription) -> Void) {
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

    public func sendOfferToPeer(_ sdp: RTCSessionDescription, isSend: Bool) {
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sdp = sdp.sdp
        let sendSDPOffer = SendOfferSDPReq(id: isSend ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER",
                                           brokerAddress: config.brokerAddress,
                                           token: Chat.sharedInstance.token ?? "",
                                           topic: isSend ? config.topicVideoSend : config.topicVideoReceive,
                                           sdpOffer: sdp,
                                           mediaType: .video)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else { return }
        send(data) // signaling server - peerConnection
    }

    public func send(_ data: Data) {
        if let content = String(data: data, encoding: .utf8) {
            Chat.sharedInstance.prepareToSendAsync(content, peerName: config.peerName)
        }
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
        // FIXME: - Fix topic to dynamic and mediaType and Topic
        let sendSDPOffer = SendOfferSDPReq(id: "SEND_SDP_OFFER", brokerAddress: config.brokerAddress, token: Chat.sharedInstance.token ?? "", topic: config.topicVideoReceive, sdpOffer: sdp.sdp, mediaType: .video)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else { return }
        send(data)
    }

    private func createMediaSenders() {
        let streamId = "stream"

        // Audio
//        let audioTrack = createAudioTrack()
//        peerConnection?.add(audioTrack, streamIds: [streamId])

        // Video
        let videoTrack = createVideoTrack()
        localVideoTrack = videoTrack
        peerConnection?.add(videoTrack, streamIds: [streamId])
        remoteVideoTrack = peerConnection?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack

        // Data Channel
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            localDataChannel = dataChannel
        }
    }

    public func closeSignalingServerCall() {
        let close = CloseSessionReq(token: Chat.sharedInstance.token ?? "")
        guard let data = try? JSONEncoder().encode(close) else { return }
        send(data)
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

    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = peerConnection?.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            Chat.sharedInstance.logger?.log(title: "warning: Couldn't create data channel")
            return nil
        }
        return dataChannel
    }

    public func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer,
              let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }),
              let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last(where: { format in
                  let width = CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == 1920
                  let height = CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == 1080
                  return width && height
              }), // TODO: - must chose resulation from configVideo
              let maxFrameRate = format.videoSupportedFrameRateRanges.last?.maxFrameRate
        else { return }

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
//        remoteVideoRenderer = renderer
        remoteVideoTrack?.add(renderer)
    }
}

// MARK: - RTCPeerConnectionDelegate

public extension WebRTCClient {
    func peerConnection(_: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        Chat.sharedInstance.logger?.log(title: "signaling state changed", message: "\(String(describing: stateChanged))")
    }

    func peerConnection(_: RTCPeerConnection, didAdd _: RTCMediaStream) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did add stream")
//        if let track = stream.videoTracks.first , let renderer = remoteVideoRenderer {
//            Chat.sharedInstance.logger?.log(title: "video track faund")
//            track.add(renderer)
//        }
    }

    func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {
        Chat.sharedInstance.logger?.log(title: "peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_: RTCPeerConnection) {
        Chat.sharedInstance.logger?.log(title: "peerConnection should negotiate")
    }

    func peerConnection(_: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        Chat.sharedInstance.logger?.log(title: "peerConnection new connection state", message: "\(String(describing: newState))")
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
        // FIXME: - Fix topic to dynamic
        let sendIceCandidate = SendCandidateReq(id: "ADD_ICE_CANDIDATE", token: Chat.sharedInstance.token ?? "", topic: config.topicVideoSend, candidate: IceCandidate(from: candidate))
        guard let data = try? JSONEncoder().encode(sendIceCandidate) else { return }
        send(data)
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

public extension WebRTCClient {
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

// MARK: - OnReceive Message from Async Server

extension WebRTCClient {
    func messageReceived(_ message: AsyncMessage) {
        guard let data = message.content?.data(using: .utf8), let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else { return }
        switch ms.id {
        case .sessionRefresh, .createSession:
            // nothing to do for now
            break
        case .addIceCandidate:
            guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else { return }
            peerConnection?.add(candidate.rtcIceCandidate, completionHandler: { error in
                if let error = error {
                    Chat.sharedInstance.logger?.log(title: "CHAT_SDK:", message: "\(error)")
                }
            })
        case .processSdpAnswer:
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data) else { return }
            peerConnection?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { _ in })
        case .close:
            break
        case .getKeyFrame:
            break
        case .stopAll:
            break
        case .stop:
            break
        case .sessionNewCreated:
            break
        case .unkown:
            break
        }
        Chat.sharedInstance.logger?.log(title: "call on Message", message: String(data: data, encoding: .utf8))
    }
}

enum WebRTCMessageType: String, Decodable {
    case createSession
    case sessionNewCreated
    case sessionRefresh
    case getKeyFrame
    case addIceCandidate
    case processSdpAnswer
    case close
    case stopAll = "STOPALL"
    case stop
    case unkown

    // prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else {
            self = .unkown
            return
        }
        self = WebRTCMessageType(rawValue: value) ?? .unkown
    }
}

struct WebRTCAsyncMessage: Decodable {
    let id: WebRTCMessageType
}
