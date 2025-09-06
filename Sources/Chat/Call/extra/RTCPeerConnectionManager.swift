//
// RTCPeerConnectionManager.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Darwin
import Foundation
@preconcurrency import WebRTC
import ChatCore
import ChatModels
import Async

@ChatGlobalActor
public class RTCPeerConnectionManager: NSObject, RTCPeerConnectionDelegate {
    private var chat: ChatInternalProtocol?
    private var config: WebRTCConfig
    var logFile: RTCFileLogger?
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let callId: Int
    private var videoCapturer: RTCVideoCapturer?
    private var subscribed = false
    public var onAddVideoTrack:( (_ track: RTCVideoTrack, _ mid: String) -> Void )? = nil
    public var onAddAudioTrack:( (_ track: RTCAudioTrack, _ mid: String) -> Void )? = nil

    /// Peer connection
    public let pf: RTCPeerConnectionFactory
    private let pcSend: RTCPeerConnection
    private let pcReceive: RTCPeerConnection
    
    public var constraints: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
                                                kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue]

    public init(chat: ChatInternalProtocol, config: WebRTCConfig, callId: Int) {
        self.chat = chat
        self.callId = callId
        self.config = config
        RTCInitializeSSL()
        
        pf = RTCPeerConnectionFactory(encoderFactory: RTCDefaultVideoEncoderFactory.default,
                                      decoderFactory: RTCDefaultVideoDecoderFactory.default)
       
        let op = RTCPeerConnectionFactoryOptions()
        pf.setOptions(op)
        var rtcConfig: RTCConfiguration {
            let rtcConfig = RTCConfiguration()
            rtcConfig.sdpSemantics = .unifiedPlan
            rtcConfig.iceTransportPolicy = .relay
            rtcConfig.continualGatheringPolicy = .gatherContinually
            rtcConfig.iceServers = config.iceServers
            return rtcConfig
        }
        
        guard let peerConnectionSend = pf.peerConnection(
            with: rtcConfig,
            constraints: .init(
                mandatoryConstraints: nil,
                optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
            ),
            delegate: nil
        )
        else { fatalError("failed to init peer connection send") }
        pcSend = peerConnectionSend
        
        guard let peerConnectionReceive = pf.peerConnection(
            with: rtcConfig,
            constraints: .init(
                mandatoryConstraints: constraints,
                optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
            ),
            delegate: nil
        )
        else { fatalError("failed to init peer connection receive") }
        pcReceive = peerConnectionReceive
        
        super.init()
        if self.chat?.config.callConfig.logWebRTC == true {
            print(config)
            // Console output
            RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)
            // File output
            saveLogsToFile()
        }
       
        pcSend.delegate = self
        pcReceive.delegate = self
    }

    deinit {
        print("deinit RTCPeerConnectionManager client called")
    }
}

// MARK: - RTCPeerConnectionDelegate

public extension RTCPeerConnectionManager {
    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        Task { @ChatGlobalActor in
            log("didChange state signaling for \(peerConnection == pcSend ? "send" : "receive")")
        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        Task { @ChatGlobalActor in
            log("\(peerConnection == pcSend ? "send" : "receive") \("did add stream")")
        }
    }

    nonisolated func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        Task { @ChatGlobalActor in
            log("peer connection should negotiate for \(peerConnection == pcSend ? "send" : "receive")")
        }
    }
    
    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
//        Task { @ChatGlobalActor [weak self] in
//            guard let self = self else {
//                self?.log("self was nil in peerconnection didchange state")
//                return
//            }
//            self.log("\(self.getPCName(peerConnection)) connection state changed to: \(String(describing: newState.stringValue))")
//            switch newState {
//            case .connected, .completed:
//                self.setConnectedState(peerConnection: peerConnection)
//            case .disconnected:
//                self.setDisconnectedState(peerConnection: peerConnection)
//            case .failed:
//                self.reconnectAndGetOffer(peerConnection)
//            default:
//                break
//            }
//            self.delegate?.didIceConnectionStateChanged(iceConnectionState: IceConnectionState(rawValue: newState.rawValue))
//        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didChange _: RTCIceGatheringState) {
        Task { @ChatGlobalActor in
            log("did change gathering ice state for \(peerConnection == pcSend ? "send" : "receive")")
        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        Task { @ChatGlobalActor in
            sendGeneratedIce(candidate, direction: peerConnection == pcSend ? .send : .receive)
        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
        Task { @ChatGlobalActor in
            log("did remove candidate(s) for \(peerConnection == pcSend ? "send" : "receive")")
        }
    }

    nonisolated func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}
    
    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        
        let transceiver = peerConnection.transceivers.first(where: { $0.receiver == rtpReceiver })
        
        
        if let audioTrack = rtpReceiver.track as? RTCAudioTrack, let mid = transceiver?.mid {
            audioTrack.isEnabled = true
            Task { @ChatGlobalActor in
                onAddAudioTrack?(audioTrack, mid)
                log("New audio track has been added with mid: \(mid)")
            }
        }
       
        if let videoTrack = rtpReceiver.track as? RTCVideoTrack, let mid = transceiver?.mid {
            videoTrack.isEnabled = true
            Task { @ChatGlobalActor in
                onAddVideoTrack?(videoTrack, mid)
                log("New video track has been added with mid: \(mid)")
            }
        }
    }
    
    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: RTCMediaStream) {
        Task { @ChatGlobalActor in
            log("peer connection did remove \(peerConnection == pcSend ? "send" : "receive")")
        }
    }
}

// MARK: Session description management

public extension RTCPeerConnectionManager {
   
    internal func generateSDPOffer(video: Bool, topic: String, direction: RTCDirection) async throws {
        if direction == .send {
            let sdp = try await pcSend.offer(for: .init(mandatoryConstraints: nil, optionalConstraints: nil))
            try await pcSend.setLocalDescription(sdp)
            sendOfferToPeer(
                idType: .sendSdpOffer,
                sdp: sdp,
                topic: topic,
                mediaType: video ? .video : .audio
            )
        } else {
            let sdp = try await pcReceive.offer(for: .init(mandatoryConstraints: nil, optionalConstraints: nil))
            try await pcSend.setLocalDescription(sdp)
            sendOfferToPeer(
                idType: .sendSdpOffer,
                sdp: sdp,
                topic: topic,
                mediaType: video ? .video : .audio
            )
        }
    }
    
    private func sendOfferToPeer(idType: CallMessageType, sdp: RTCSessionDescription, topic: String, mediaType: ReveiveMediaItemType) {
        let sendSDPOffer = SendOfferSDPReq(brokerAddress: config.brokerAddress.joined(separator: ","),
                                           topic: topic,
                                           sdpOffer: sdp.sdp,
                                           mediaType: mediaType)
        sendAsyncMessage(sendSDPOffer, idType)
    }
    
    public func setRemoteDescription(_ remoteSDP: RemoteSDPAnswerRes, direction: RTCDirection) {
        let pc = direction == .send ? pcSend : pcReceive
        let sdp = RTCSessionDescription(type: .answer, sdp: remoteSDP.sdpAnswer)
        Task {
            do {
                try await pc.setRemoteDescription(sdp)
            } catch {
                self.log("error in setRemoteDescroptoin with for \(direction) sdp: \(remoteSDP.sdpAnswer) with error: \(error)")
            }
        }
    }
   
    func processSDPOffer(_ offer: RemoteSDPOfferRes) {
        let sdp = RTCSessionDescription(type: .offer, sdp: offer.sdpOffer)
        Task {
            do {
                try await pcReceive.setRemoteDescription(sdp)
                for item in offer.addition {
                    let answer = try await pcReceive.answer(for: item.constraints)
                    try await pcReceive.setLocalDescription(answer)
                    
                    let req = ReceiveSDPAnswerReq(
                        sdpAnswer: answer.sdp,
                        addition: [item],
                        brokerAddress: config.brokerAddress.joined(separator: ",")
                    )
                    sendAsyncMessage(req, .receiveSdpAnswer)
                }
            } catch {
                log("Failed to set remote offer description and create an answer")
            }
        }
    }
}

// MARK: Subscription

extension RTCPeerConnectionManager {
    func subscribeToReceiveOffers(_ media: ReceivingMedia) {
        for item in media.recvList {
            let req = CallSubscribeRequest(
                brokerAddress: config.brokerAddress.joined(separator: ","),
                addition: [item.toAddition]
            )
            sendAsyncMessage(req, subscribed ? .update : .subscribe)
            if !subscribed {
                subscribed = true
            }
        }
    }
}

// MARK: Ice management

extension RTCPeerConnectionManager {
    public func setPeerIceCandidate(ice: IceCandidate, direction: RTCDirection) {
        let pc = direction == .send ? pcSend : pcReceive
        Task {
            do {
                while pc.remoteDescription == nil {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
                try await pc.add(ice.rtcIceCandidate)
            } catch {
                log("Failed set \(direction) peer add ice candidate error: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendGeneratedIce(_ candidate: RTCIceCandidate, direction: RTCDirection) {
        let relayStr = candidate.sdp.contains("typ relay") ? "Yes ✅✅✅✅✅✅" : "No ⛔️⛔️⛔️⛔️⛔️⛔️⛔️"
        log("did generate ICE Candidate for: \(direction == .send ? "send" : "receive") is relayType:\(relayStr)")
        let sendIceCandidate = SendCandidateReq(iceCandidate: IceCandidate(from: candidate),
                                                brokerAddress: config.brokerAddress.joined(separator: ",")
        )
        sendAsyncMessage(sendIceCandidate, .sendIceCandidate)
    }
}

// MARK: Track mangement

extension RTCPeerConnectionManager {
    public func addAudioTrack(_ track: RTCAudioTrack, direction: RTCDirection, streamIds: [String] = ["stream0"]) {
        if direction == .send {
            pcSend.add(track, streamIds: streamIds)
        }
    }
    
    public func addVideoTrack(_ track: RTCVideoTrack, direction: RTCDirection, streamIds: [String] = ["stream0"]) {
        if direction == .send {
            pcSend.add(track, streamIds: streamIds)
        }
    }
    
    public func createAudioSenderTrack(trackId: String = "audio0") -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = pf.audioSource(with: audioConstrains)
        return pf.audioTrack(with: audioSource, trackId: trackId)
    }
    
    public func createVideoSenderTrack(trackId: String = "video0", fileName: String? = nil) -> RTCVideoTrack {
        let videoSource = pf.videoSource()
        if TARGET_OS_SIMULATOR != 0 {
            videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        } else {
            videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        return pf.videoTrack(with: videoSource, trackId: "video0")
    }
}

// MARK: Configure audio session

public extension RTCPeerConnectionManager {
    func configureAudioSession() {
        log("configure audio session")
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat)
        } catch {
            log("error changeing AVAudioSession category with error: \(error.localizedDescription)")
        }
        rtcAudioSession.unlockForConfiguration()
    }

    func toggleSpeaker() {
        audioQueue.async { [weak self] in
            Task { @ChatGlobalActor in
                let on = !(self?.rtcAudioSession.isActive ?? false)
                self?.log("request to setSpeaker:\(on)")
                guard let self = self else {
                    self?.log("self was nil set speaker mode!")
                    return
                }

                self.rtcAudioSession.lockForConfiguration()
                do {
                    try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                    try self.rtcAudioSession.overrideOutputAudioPort(on ? .speaker : .none)
                    if on { try self.rtcAudioSession.setActive(true) }
                } catch {
                    self.log("can't change audio speaker")
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }

    private func destroyAudioSession() {
        audioQueue.async { [weak self] in
            Task { @ChatGlobalActor in
                guard let self = self else {
                    self?.log("self was nil set speaker mode!")
                    return
                }
                self.rtcAudioSession.lockForConfiguration()
                do {
                    try self.rtcAudioSession.setActive(false)
                } catch {
                    self.log("can't change audio speaker")
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }
}

extension RTCPeerConnectionManager {
    func log(_ message: String) {
        chat?.logger.log(title: "RTCPeerConnectionManager", message: message, persist: false, type: .internalLog)
    }
    
    func saveLogsToFile() {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let logFilePath = "WEBRTC-LOG"
            let url = dir.appendingPathComponent(logFilePath)
            log("created path for log is :\(url.path)")

            logFile = RTCFileLogger(dirPath: url.path, maxFileSize: 100 * 1024)
            logFile?.severity = .info
            logFile?.start()
        }
    }
}

// MARK: Other actions

extension RTCPeerConnectionManager {
    
    /// Client can call this to dissconnect from peer.
    public func dispose() {
        pcSend.close()
        pcReceive.close()
        destroyAudioSession()
    }
    
    func startCaptureLocalVideo(fileName: String?, front: Bool) {
        let fps = self.config.callConfig.targetFPS
        
        let videoCapturer = videoCapturer as? RTCCameraVideoCapturer
        if let selectedCamera = getCamera(front: front),
           let format = getCameraFormat(front: front) {
            DispatchQueue.global(qos: .background).async {
                videoCapturer?.startCapture(with: selectedCamera, format: format, fps: fps)
            }
        } else if let videoCapturer = videoCapturer as? RTCFileVideoCapturer, let fileName = fileName {
            videoCapturer.startCapturing(fromFileNamed: fileName) { _ in }
        }
    }
    
    private func getCamera(front: Bool) -> AVCaptureDevice? {
        RTCCameraVideoCapturer
            .captureDevices()
            .first(where: { $0.position == (front ? .front : .back)})
    }
    
    public func getCameraFormat(front: Bool) -> AVCaptureDevice.Format? {
        guard let frontCamera = getCamera(front: front) else { return nil }
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last { format in
            let maxFrameRate = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate <= Float64(config.callConfig.targetFPS) })?.maxFrameRate ?? Float64(config.callConfig.targetFPS)
            let targetFPS = Int(maxFrameRate)
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            return dimensions.width == config.callConfig.targetVideoWidth && dimensions.height == config.callConfig.targetVideoHeight && Int(maxFrameRate) <= targetFPS
        }
        return format
    }
    
    @discardableResult
    func sendAsyncMessage<T: Encodable>(_ req : T, _ type: CallMessageType) -> String? {
        let callInstance = CallServerWrapper(id: type,
                                             token: chat?.config.token ?? "",
                                             chatId: callId,
                                             payload: req)
        guard let content = callInstance.jsonString else { return nil }
        let wrapper = CallAsyncMessageWrapper(content: content, peerName: config.peerName)
        (chat?.call as? InternalCallProtocol)?.send(wrapper)
        return callInstance.uniqueId
    }
}
