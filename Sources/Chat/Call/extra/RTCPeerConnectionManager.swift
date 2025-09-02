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
public class RTCPeerConnectionManager: NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    private var chat: ChatInternalProtocol?
    private var config: WebRTCConfig
    private var delegate: WebRTCClientDelegate?
    var logFile: RTCFileLogger?
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let callId: Int
    public var videoCapturer: RTCVideoCapturer?
    
    /// Peer connection
    public let pf: RTCPeerConnectionFactory
    private let pcSend: RTCPeerConnection
    private let pcReceive: RTCPeerConnection
    
    public var constraints: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
                                                kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue]

    public init(chat: ChatInternalProtocol, config: WebRTCConfig, callId: Int, delegate: WebRTCClientDelegate? = nil) {
        self.chat = chat
        self.callId = callId
        self.config = config
        self.delegate = delegate
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
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
//        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) did add stream")
//            if let callParticipntUserRCT = callParticipantFor(peerConnection) {
//                if let videoTrack = stream.videoTracks.first, let topic = getTopicForPeerConnection(peerConnection), let renderer = callParticipntUserRCT.videoRTC.renderer {
//                    customPrint("\(getPCName(peerConnection)) did add stream video track topic: \(topic)")
//                    videoTrack.add(renderer)
//                }
//                
//                if let audioTrack = stream.audioTracks.first, let topic = getTopicForPeerConnection(peerConnection) {
//                    customPrint("\(getPCName(peerConnection)) did add stream audio track topic: \(topic)")
//                    callParticipntUserRCT.audioRTC.pc.add(audioTrack, streamIds: [topic])
//                }
//            }
//        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: RTCMediaStream) {
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) did remove stream")
//        }
    }

    nonisolated func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) should negotiate")
//        }
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
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) did change new state")
//        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        Task { @ChatGlobalActor in
            sendGeneratedIce(candidate, direction: peerConnection == pcSend ? .send : .receive)
        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) did remove candidate(s)")
//        }
    }

    nonisolated func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}
    
    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didAdd rtpReceiver: RTCRtpReceiver, streams mediaStreams: [RTCMediaStream]) {
        if let audioTrack = rtpReceiver.track as? RTCAudioTrack {
            audioTrack.isEnabled = true
        }
    }
}

// MARK: - RTCDataChannelDelegate

public extension RTCPeerConnectionManager {
    nonisolated func dataChannel(_: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        Task { @ChatGlobalActor in
            if buffer.isBinary {
                self.delegate?.dataChannelDidReceive(data: buffer.data)
            } else {
                self.delegate?.dataChannelDidReceive(message: String(data: buffer.data, encoding: String.Encoding.utf8)!)
            }
        }
    }

    nonisolated func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        Task { @ChatGlobalActor in
            log("data channel did changeed state to \(dataChannel.readyState)")
        }
    }
}

// MARK: Session description management

public extension RTCPeerConnectionManager {
   
    private func reconnectAndGetOffer(_ peerConnection: RTCPeerConnection) {
//        guard let callParticipantuserRTC = callParticipantFor(peerConnection) else {
//            customPrint("can't find topic to reconnect peerconnection", isGuardNil: true)
//            return
//        }
//        Task {
//            try? await sendSDPOffers(callParticipantUserRTC: callParticipantuserRTC)
//        }
    }
    
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
    
    private func sendOfferToPeer(idType: CallMessageType, sdp: RTCSessionDescription, topic: String, mediaType: MediaType) {
        let sendSDPOffer = SendOfferSDPReq(brokerAddress: config.brokerAddress.joined(separator: ","),
                                           topic: topic,
                                           sdpOffer: sdp.sdp,
                                           mediaType: mediaType)
        sendAsyncMessage(sendSDPOffer, idType)
    }
    
    public func setRemoteDescription(_ remoteSDP: RemoteSDPAnswerRes, direction: RTCDirection) {
        if direction == .send {
            let sdp = RTCSessionDescription(type: .answer, sdp: remoteSDP.sdpAnswer)
            pcSend.setRemoteDescription(sdp) { error in
                if let error = error {
                    Task { @ChatGlobalActor in
                        self.log("error in setRemoteDescroptoin with for send sdp: \(remoteSDP.sdpAnswer) with error: \(error)")
                    }
                }
            }
        } else {
            let sdp = RTCSessionDescription(type: .answer, sdp: remoteSDP.sdpAnswer)
            pcReceive.setRemoteDescription(sdp) { error in
                if let error = error {
                    Task { @ChatGlobalActor in
                        self.log("error in setRemoteDpcSendescroptoin with for receive sdp: \(remoteSDP.sdpAnswer) with error: \(error)")
                    }
                }
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
            sendAsyncMessage(req, .subscribe)
        }
    }
}

// MARK: Ice management

extension RTCPeerConnectionManager {
    public func setSendPeerIceCandidate(_ ice: IceCandidate) {
        Task {
            do {
                try await pcSend.add(ice.rtcIceCandidate)
            } catch {
                log("Failed set send peer add ice candidate error: \(error.localizedDescription)")
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
    
    public func createAudioSenderTrack(topic: String, trackId: String = "audio0") -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = pf.audioSource(with: audioConstrains)
        let track = pf.audioTrack(with: audioSource, trackId: trackId)
        return track
    }
    
    public func createVideoSenderTrack(topic: String, trackId: String = "video0", fileName: String? = nil) -> RTCVideoTrack {
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
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
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
                    try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
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
    private func deActiveFirstVideoSession(_ callParticipant: CallParticipantUserRTC) {
//        callParticipant.videoRTC.setTrackEnable(false)
//        chat?.delegate?.chatEvent(event: .call(.maxVideoSessionLimit(.init(uniqueId: nil, result: callParticipant.callParticipant, time: Int(Date().timeIntervalSince1970), typeCode: nil))))
    }
    
    private func reActiveVideoSession() {
//        callParticipantsUserRTC.filter { $0.callParticipant.video == true && $0.videoRTC.isVideoTrackEnable == false }.forEach { callParticipant in
//            callParticipant.videoRTC.setTrackEnable(true)
//            chat?.delegate?.chatEvent(event: .call(.maxVideoSessionLimit(.init(uniqueId: nil, result: callParticipant.callParticipant, time: Int(Date().timeIntervalSince1970), typeCode: nil))))
//        }
    }

    public func removeCallParticipant(_ callParticipant: CallParticipant) {
//        if let index = callParticipantsUserRTC.firstIndex(where: { $0.callParticipant.userId == callParticipant.userId }) {
//            callParticipantsUserRTC[index].close()
//            callParticipantsUserRTC.remove(at: index)
//        }
    }
    
    /// Client can call this to dissconnect from peer.
    public func dispose() {
        pcSend.close()
        pcReceive.close()
        destroyAudioSession()
    }
    
    func toggleCamera() {
//        meCallParticipntUserRCT?.toggleCamera()
    }

    func toggle() {
//        meCallParticipntUserRCT?.toggleMute()
    }

    func switchCamera() {
//        meCallParticipntUserRCT?.switchCameraPosition()
    }
    
    private func isSendTopic(topic: String) -> Bool {
        topic == config.topicAudioSend || topic == config.topicVideoSend
    }

    func rawTopicName(topic: String) -> String {
        topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
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
