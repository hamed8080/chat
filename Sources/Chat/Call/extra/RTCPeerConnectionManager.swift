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
    private var answerReceived: [String: RTCPeerConnection] = [:]
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
    
    public var constraints: [String: String] = [kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueFalse,
                                                kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueFalse]

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
            rtcConfig.iceServers = [RTCIceServer(urlStrings: config.iceServers, username: config.userName!, credential: config.password!)]
            return rtcConfig
        }
        
        guard let peerConnectionSend = pf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]), delegate: nil)
        else { fatalError("failed to init peer connection send") }
        pcSend = peerConnectionSend
        
        guard let peerConnectionReceive = pf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]), delegate: nil)
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


    public func setRemoteIce() {
//        pc.add(rtcIce) { error in
//            if let error = error {
//                print("error on add ICE Candidate with ICE:\(rtcIce.sdp) \(error)")
//            }
//        }
    }
    
    public func setRemoteDescription(_ remoteSDP: RemoteSDPRes) {
//        guard let sdp = remoteSDP.rtcSDP else { return }
//        pc.setRemoteDescription(sdp) { error in
//            if let error = error {
//                print("error in setRemoteDescroptoin with for topic:\(remoteSDP.topic) sdp: \(remoteSDP.rtcSDP) with error: \(error)")
//            }
//        }
    }

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

    private func setConnectedState(peerConnection: RTCPeerConnection) {
//        customPrint("--- \(getPCName(peerConnection)) connected ---", isSuccess: true)
//        delegate?.didConnectWebRTC()
    }

    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(peerConnection: RTCPeerConnection) {
//        customPrint("--- \(getPCName(peerConnection)) disconnected ---", isGuardNil: true)
//        delegate?.didDisconnectWebRTC()
    }

    /// Client can call this to dissconnect from peer.
    public func clearResourceAndCloseConnection() {
//        callParticipantsUserRTC.forEach { callParticipantUserRTC in
//            if let index = callParticipantsUserRTC.firstIndex(where: { $0 == callParticipantUserRTC }) {
//                callParticipantsUserRTC[index].close()
//            }
//        }
//        destroyAudioSession()
//        let close = CloseSessionReq(peerName: config.peerName, token: chat?.config.token ?? "")
//        (chat?.call as? InternalCallProtocol)?.send(close)
//        logFile?.stop()
//        callParticipantsUserRTC = []
    }

    public func sendOfferToPeer(idType: CallMessageType, sdp: RTCSessionDescription, topic: String, mediaType: Mediatype) {
        let sendSDPOffer = SendOfferSDPReq(id: idType,
                                           peerName: config.peerName,
                                           brokerAddress: config.firstBorokerAddressWeb,
                                           token: chat?.config.token ?? "",
                                           topic: topic,
                                           sdpOffer: sdp.sdp,
                                           mediaType: mediaType,
                                           chatId: callId)
        (chat?.call as? InternalCallProtocol)?.send(sendSDPOffer)
    }

    deinit {
        print("deinit webrtc client called")
    }

    func customPrint(_ message: String, _ error: Error? = nil, isSuccess: Bool = false, isGuardNil: Bool = false) {
        let errorMessage = error != nil ? " with error:\(error?.localizedDescription ?? "")" : ""
        let icon = isGuardNil ? "❌" : isSuccess ? "✅" : ""
        chat?.logger.log(title: "CHAT_SDK:\(icon)", message: "\(message) \(errorMessage)", persist: false, type: .internalLog)
    }

    func saveLogsToFile() {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let logFilePath = "WEBRTC-LOG"
            let url = dir.appendingPathComponent(logFilePath)
            customPrint("created path for log is :\(url.path)")

            logFile = RTCFileLogger(dirPath: url.path, maxFileSize: 100 * 1024)
            logFile?.severity = .info
            logFile?.start()
        }
    }
    
    /// check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    public func addIceToPeerConnection(_ candidate: RemoteCandidateRes) {
//        let rtcIce = candidate.rtcIceCandidate
//        if pc.remoteDescription != nil {
//            setRemoteIce(rtcIce)
//        } else {
//            iceQueue.append(rtcIce)
//            iceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
////                Task { @ChatGlobalActor in
////                    if self?.pc?.remoteDescription != nil {
////                        self?.setRemoteIce(rtcIce)
////                        self?.iceQueue.removeAll(where: { $0 == rtcIce })
////                        print("ICE added to \(self?.topic ?? "") from Queue and remaining in Queue is: \(self?.iceQueue.count ?? 0)")
////                        timer.invalidate()
////                    }
////                }
//            }
//        }
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
    
    func startCaptureLocalVideo(fileName: String?,
                                front: Bool) {
        let fps = self.config.callConfig.targetFPS
        if let videoCapturer = videoCapturer as? RTCCameraVideoCapturer,
           let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (front ? .front : .back) }),
           let format = getCameraFormat(front: front)
        {
            DispatchQueue.global(qos: .background).async {
                videoCapturer.startCapture(with: selectedCamera, format: format, fps: fps)
            }
        } else if let videoCapturer = videoCapturer as? RTCFileVideoCapturer, let fileName = fileName {
            videoCapturer.startCapturing(fromFileNamed: fileName) { _ in }
        }
    }
    
    
    public func getCameraFormat(front: Bool) -> AVCaptureDevice.Format? {
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (front ? .front : .back) }) else { return nil }
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last { format in
            let maxFrameRate = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate <= Float64(config.callConfig.targetFPS) })?.maxFrameRate ?? Float64(config.callConfig.targetFPS)
            let targetFPS = Int(maxFrameRate)
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            return dimensions.width == config.callConfig.targetVideoWidth && dimensions.height == config.callConfig.targetVideoHeight && Int(maxFrameRate) <= targetFPS
        }
        return format
    }
        
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
    
    public func setRemoteIceCandidate(_ res: RemoteCandidateRes) {
//        if isVideoTopic(topic: res.topic) {
//            addIceToPeerConnection(res)
//        } else {
//            addIceToPeerConnection(res)
//        }
    }
    
    func getOfferSDP(video: Bool) async throws -> RTCSessionDescription {
        try await pcSend.offer(for: .init(mandatoryConstraints: constraints,
                                          optionalConstraints: constraints))
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
//                self?.customPrint("self was nil in peerconnection didchange state", isGuardNil: true)
//                return
//            }
//            self.customPrint("\(self.getPCName(peerConnection)) connection state changed to: \(String(describing: newState.stringValue))")
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
//        Task { @ChatGlobalActor in
//            let relayStr = candidate.sdp.contains("typ relay") ? "Yes ✅✅✅✅✅✅" : "No ⛔️⛔️⛔️⛔️⛔️⛔️⛔️"
//            customPrint("\(getPCName(peerConnection)) did generate ICE Candidate is relayType:\(relayStr)")
//            guard let topicName = getTopicForPeerConnection(peerConnection) else {
//                customPrint("can't find topic name to send ICE Candidate", isGuardNil: true)
//                return
//            }
//            recursiveTimerForRemoteSDP(0.5, topicName, candidate, peerConnection)
//        }
    }

    private func recursiveTimerForRemoteSDP(_ interval: TimeInterval, _ topicName: String, _ candidate: RTCIceCandidate, _ peerConnection: RTCPeerConnection, _ retryCount: Int = 0) {
//        let intervals: [Int] = [2, 4, 8, 12]
//        if retryCount > intervals.count - 1 { return }
//        let nextInterval = TimeInterval(intervals[retryCount])
//        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
//            guard let self = self else { return }
//            Task { @ChatGlobalActor in
//                if self.callParticipntUserRCT(topicName)?.peerConnectionForTopic(topic: topicName)?.remoteDescription != nil {
//                    let sendIceCandidate = SendCandidateReq(peerName: self.config.peerName,
//                                                            token: self.chat?.config.token ?? "",
//                                                            topic: topicName,
//                                                            candidate: IceCandidate(from: candidate).replaceSpaceSdpIceCandidate)
//                    self.customPrint("ice sended to server")
//                    (self.chat?.call as? InternalCallProtocol)?.send(sendIceCandidate)
//                } else {
//                    self.recursiveTimerForRemoteSDP(nextInterval, topicName, candidate, peerConnection, retryCount + 1)
//                    let pcName = self.getPCName(peerConnection)
//                    self.customPrint("answer is not present yet for \(pcName) timer will fire in \(nextInterval) second", isGuardNil: true)
//                }
//            }
//        }
    }

    nonisolated func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
//        Task { @ChatGlobalActor in
//            customPrint("\(getPCName(peerConnection)) did remove candidate(s)")
//        }
    }

    nonisolated func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}

    private func isSendTopic(topic: String) -> Bool {
        topic == config.topicAudioSend || topic == config.topicVideoSend
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

    func rawTopicName(topic: String) -> String {
        topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
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
            customPrint("data channel did changeed state to \(dataChannel.readyState)")
        }
    }
}

// MARK: - OnReceive Message from Async Server

extension RTCPeerConnectionManager {
    func stopAllSessions() {
        let stop = StopAllSessionReq(peerName: self.config.peerName, token: self.chat?.config.token ?? "")
        (chat?.call as? InternalCallProtocol)?.send(stop)
    }
}

// configure audio session
public extension RTCPeerConnectionManager {
    func configureAudioSession() {
        customPrint("configure audio session")
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch {
            customPrint("error changeing AVAudioSession category", error, isGuardNil: true)
        }
        rtcAudioSession.unlockForConfiguration()
    }

    func toggleSpeaker() {
        audioQueue.async { [weak self] in
            Task { @ChatGlobalActor in
                let on = !(self?.rtcAudioSession.isActive ?? false)
                self?.customPrint("request to setSpeaker:\(on)")
                guard let self = self else {
                    self?.customPrint("self was nil set speaker mode!", isGuardNil: true)
                    return
                }

                self.rtcAudioSession.lockForConfiguration()
                do {
                    try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                    try self.rtcAudioSession.overrideOutputAudioPort(on ? .speaker : .none)
                    if on { try self.rtcAudioSession.setActive(true) }
                } catch {
                    self.customPrint("can't change audio speaker", error, isGuardNil: true)
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }

    func destroyAudioSession() {
        audioQueue.async { [weak self] in
            Task { @ChatGlobalActor in
                guard let self = self else {
                    self?.customPrint("self was nil set speaker mode!", isGuardNil: true)
                    return
                }
                self.rtcAudioSession.lockForConfiguration()
                do {
                    try self.rtcAudioSession.setActive(false)
                } catch {
                    self.customPrint("can't change audio speaker", error, isGuardNil: true)
                }
                self.rtcAudioSession.unlockForConfiguration()
            }
        }
    }
}

public extension RTCPeerConnectionManager {
    func setOffers() {
//        callParticipantsUserRTC.forEach { callParticipantUserRTC in
//            let isMe = callParticipantUserRTC.isMe
//            Task {
//                try? await sendSDPOffers(callParticipantUserRTC: callParticipantUserRTC)
//            }
//        }
    }

    internal func reconnectAndGetOffer(_ peerConnection: RTCPeerConnection) {
//        guard let callParticipantuserRTC = callParticipantFor(peerConnection) else {
//            customPrint("can't find topic to reconnect peerconnection", isGuardNil: true)
//            return
//        }
//        Task {
//            try? await sendSDPOffers(callParticipantUserRTC: callParticipantuserRTC)
//        }
    }
    
    internal func sendSDPOffers(_ callParticipantUserRTC: CallParticipantUserRTC) async throws {
//        let audioSdp = try await getOfferSDP(video: false)
//        sendOfferToPeer(
//            idType: isMe ? .sendSdpOffer : .receiveSdpOffer,
//            sdp: audioSdp,
//            topic: callParticipantUserRTC.audioRTC.topic,
//            mediaType: .audio
//        )
//        
//        let videoSdp = try await getOfferSDP(video: true)
//        sendOfferToPeer(
//            idType: isMe ? .sendSdpOffer : .receiveSdpOffer,
//            sdp: videoSdp,
//            topic: callParticipantUserRTC.videoRTC.topic,
//            mediaType: .video
//        )
    }
    
    internal func generateSendSDPOffer(video: Bool, topic: String) async throws {
        let sdp = try await pcSend.offer(for: .init(mandatoryConstraints: constraints, optionalConstraints: constraints))
        sendOfferToPeer(
            idType: .sendSdpOffer,
            sdp: sdp,
            topic: topic,
            mediaType: .video
        )
    }
}

