//
// WebRTCClient.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Darwin
import FanapPodAsyncSDK
import Foundation
import WebRTC

public protocol WebRTCClientDelegate: AnyObject {
    func didIceConnectionStateChanged(iceConnectionState: RTCIceConnectionState)
    func didReceiveData(data: Data)
    func didReceiveMessage(message: String)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.
public class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    public static var instance: WebRTCClient? // for call methods when new message arrive from server
    private var answerReceived: [String: RTCPeerConnection] = [:]

    private var config: WebRTCConfig
    private var delegate: WebRTCClientDelegate?
    public var usersRTC: [UserRCT] = []
    private var videoCapturer: RTCVideoCapturer?
    private var localDataChannel: RTCDataChannel?
    private var isFrontCamera: Bool = true
    private var videoSource: RTCVideoSource?
    private var iceQueue: [(pc: RTCPeerConnection, ice: RTCIceCandidate)] = []
    var targetLocalVideoWidth: Int32 = 640
    var targetLocalVideoHight: Int32 = 480
    var targetFPS: Int32 = 15
    var logFile: RTCFileLogger?

    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")

    public init(config: WebRTCConfig, delegate: WebRTCClientDelegate? = nil) {
        self.delegate = delegate
        self.config = config
        RTCInitializeSSL()
        print(config)
        super.init()
        Chat.sharedInstance.callState = .initializeWebrtc
        WebRTCClient.instance = self

        // Console output
        RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)

        // File output
        saveLogsToFile()
    }

    func createPeerCpnnectionFactoryForTopic(topic: String?) {
        if let topic = topic {
            let encoder = RTCDefaultVideoEncoderFactory.default
            let decoder = RTCDefaultVideoDecoderFactory.default
            let pcf = RTCPeerConnectionFactory(encoderFactory: encoder, decoderFactory: decoder)
            let op = RTCPeerConnectionFactoryOptions()
            //            op.disableEncryption = true
            pcf.setOptions(op)
            if let index = usersRTC.indexFor(topic: topic) {
                usersRTC[index].setPeerFactory(pcf)
            }
        }
    }

    private func createPeerConnection(_ topic: String?) {
        if let topic = topic,
           let pcf = usersRTC.userFor(topic: topic)?.pf,
           let constraints = usersRTC.userFor(topic: topic)?.constraints,
           let pc = pcf.peerConnection(with: rtcConfig, constraints: .init(mandatoryConstraints: constraints, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]), delegate: nil)
        {
            pc.delegate = self
            if let index = usersRTC.indexFor(topic: topic) {
                usersRTC[index].setPeerConnection(pc)
            }
        } else {
            customPrint("can't create peerConnection check configration and initialization in gropup", isGuardNil: true)
        }
    }

    private var rtcConfig: RTCConfiguration {
        let rtcConfig = RTCConfiguration()
        rtcConfig.sdpSemantics = .unifiedPlan
        rtcConfig.iceTransportPolicy = .relay
        rtcConfig.continualGatheringPolicy = .gatherContinually
        rtcConfig.iceServers = [RTCIceServer(urlStrings: config.iceServers, username: config.userName!, credential: config.password!)]
        return rtcConfig
    }

    public func createTopic(topic: String, direction: RTCDirection, renderer: RTCVideoRenderer? = nil) {
        usersRTC.append(.init(topic: topic, direction: direction, renderer: renderer))
        createPeerCpnnectionFactoryForTopic(topic: topic)
        createPeerConnection(topic)
    }

    public func createSession() {
        configureAudioSession()
        let session = CreateSessionReq(turnAddress: config.turnAddress, brokerAddress: config.brokerAddressWeb, token: Chat.sharedInstance.token ?? "")
        if let data = try? JSONEncoder().encode(session) {
            send(data)
        } else {
            customPrint("can't create session decoder was nil", isGuardNil: true)
        }
    }

    /// order is matter in this function
    public func addCallParticipant(_ callParticipant: CallParticipant, direction: RTCDirection) {
        createTopic(topic: callParticipant.topics.topicVideo, direction: direction, renderer: TARGET_OS_SIMULATOR != 0 ? RTCEAGLVideoView(frame: .zero) : RTCMTLVideoView(frame: .zero))
        createTopic(topic: callParticipant.topics.topicAudio, direction: direction)

        // create media senders for both audio and video senders
        if usersRTC.userFor(topic: config.topicVideoSend ?? "")?.videoTrack == nil {
            createMediaSenders()
        }

        if direction == .receive {
            addReceiveVideoStream(topic: callParticipant.topics.topicVideo)
            addReceiveAudioStream(topic: callParticipant.topics.topicAudio)
            getOfferAndSendToPeer(topic: callParticipant.topics.topicVideo)
            getOfferAndSendToPeer(topic: callParticipant.topics.topicAudio)
        }

        if let index = usersRTC.indexFor(topic: callParticipant.topics.topicVideo) {
            usersRTC[index].setCallParticipant(callParticipant)
            usersRTC[index].setVideo(on: callParticipant.video ?? false)
        }

        if let index = usersRTC.indexFor(topic: callParticipant.topics.topicAudio) {
            usersRTC[index].setCallParticipant(callParticipant)
            usersRTC[index].setMute(mute: callParticipant.mute)
        }
    }

    public func removeCallParticipant(_ callParticipant: CallParticipant) {
        usersRTC.removeTopic(topic: callParticipant.topics.topicVideo)
        usersRTC.removeTopic(topic: callParticipant.topics.topicAudio)
    }

    private func setConnectedState(peerConnection: RTCPeerConnection) {
        customPrint("--- \(getPCName(peerConnection)) connected ---", isSuccess: true)
        delegate?.didConnectWebRTC()
    }

    /** Called when connction state change in RTCPeerConnectionDelegate. */
    private func setDisconnectedState(peerConnection: RTCPeerConnection) {
        customPrint("--- \(getPCName(peerConnection)) disconnected ---", isGuardNil: true)
        delegate?.didDisconnectWebRTC()
    }

    /// Client can call this to dissconnect from peer.
    public func clearResourceAndCloseConnection() {
        usersRTC.forEach { userRTC in
            customPrint("--- closing \(userRTC.topic) ---", isGuardNil: true)
            userRTC.pc?.close()
        }
        let close = CloseSessionReq(token: Chat.sharedInstance.token ?? "")
        guard let data = try? JSONEncoder().encode(close) else {
            customPrint("error to encode close session request ", isGuardNil: true)
            return
        }
        logFile?.stop()
        send(data)
        usersRTC = []
        (videoCapturer as? RTCCameraVideoCapturer)?.stopCapture()
        WebRTCClient.instance = nil
    }

    public func getLocalSDPWithOffer(topic: String, onSuccess: @escaping (RTCSessionDescription) -> Void) {
        guard let mediaConstraint = usersRTC.userFor(topic: topic)?.constraints else {
            customPrint("can't find mediaConstraint to get local offer", isGuardNil: true)
            return
        }
        let constraints = RTCMediaConstraints(mandatoryConstraints: mediaConstraint, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueFalse])
        guard let pp = usersRTC.userFor(topic: topic)?.pc else {
            customPrint("can't find peerConnection in map to get local offer", isGuardNil: true)
            return
        }
        pp.offer(for: constraints, completionHandler: { sdp, error in
            if let error = error {
                self.customPrint("can't get offer SDP from SDK", error, isGuardNil: true)
            }
            guard let sdp = sdp else {
                self.customPrint("sdp was nil with no error!", isGuardNil: true)
                return
            }
            pp.setLocalDescription(sdp, completionHandler: { error in
                if let error = error {
                    self.customPrint("error setLocalDescription for offer", error, isGuardNil: true)
                    return
                }
                onSuccess(sdp)
            })
        })
    }

    public func sendOfferToPeer(_ sdp: RTCSessionDescription, topic: String) {
        let sdp = sdp.sdp
        let mediaType: Mediatype = usersRTC.userFor(topic: topic)?.isVideoTopic ?? false ? .video : .audio
        let sendSDPOffer = SendOfferSDPReq(id: isSendTopic(topic: topic) ? "SEND_SDP_OFFER" : "RECIVE_SDP_OFFER",
                                           brokerAddress: config.firstBorokerAddressWeb,
                                           token: Chat.sharedInstance.token ?? "",
                                           topic: topic,
                                           sdpOffer: sdp,
                                           mediaType: mediaType)
        guard let data = try? JSONEncoder().encode(sendSDPOffer) else {
            customPrint("error to encode SDP offer", isGuardNil: true)
            return
        }
        send(data)
    }

    public func send(_ data: Data) {
        if let content = String(data: data, encoding: .utf8) {
            Chat.sharedInstance.prepareToSendAsync(content, peerName: config.peerName)
        } else {
            customPrint("cant convert data to string in send", isGuardNil: true)
        }
    }

    private func createMediaSenders() {
        // Send Audio
        if let audioTrack = createAudioTrack(), let topicAudioSend = config.topicAudioSend, let index = usersRTC.indexFor(topic: topicAudioSend) {
            usersRTC[index].setAudioTrack(audioTrack)
            usersRTC[index].pc?.add(audioTrack, streamIds: [topicAudioSend])
        }

        // Video
        if let topicVideoSend = config.topicVideoSend, let videoTrack = createVideoTrack(), let index = usersRTC.indexFor(topic: topicVideoSend) {
            usersRTC[index].setVideoTrack(videoTrack)
            usersRTC[index].pc?.add(videoTrack, streamIds: [topicVideoSend])
            if let renderer = usersRTC.userFor(topic: topicVideoSend)?.renderer {
                startCaptureLocalVideo(renderer: renderer)
            }
        }
    }

    public func addReceiveVideoStream(topic: String) {
        if let index = usersRTC.indexFor(topic: topic) {
            var error: NSError?
            let videoReceivetransciver = usersRTC[index].pc?.addTransceiver(of: .video)
            videoReceivetransciver?.setDirection(.recvOnly, error: &error)
            if let remoteVideoTrack = videoReceivetransciver?.receiver.track as? RTCVideoTrack {
                usersRTC[index].setVideoTrack(remoteVideoTrack)
                usersRTC[index].pc?.add(remoteVideoTrack, streamIds: [topic])
                if let renderer = usersRTC[index].renderer {
                    usersRTC[index].videoTrack?.add(renderer)
                }
            }
        }
    }

    public func addReceiveAudioStream(topic: String) {
        if let index = usersRTC.indexFor(topic: topic) {
            var error: NSError?
            let transciver = usersRTC[index].pc?.addTransceiver(of: .audio)
            transciver?.setDirection(.recvOnly, error: &error)
            if let remoteAudioTrack = transciver?.receiver.track as? RTCAudioTrack {
                usersRTC[index].setAudioTrack(remoteAudioTrack)
                usersRTC[index].pc?.add(remoteAudioTrack, streamIds: [topic])
                monitorAudioLevelFor(topic: topic)
            }
        }
    }

    func monitorAudioLevelFor(topic: String) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            if let user = self.usersRTC.userFor(topic: topic) {
                user.pc?.statistics(completionHandler: { report in
                    report.statistics.values.filter { $0.type == "track" }.forEach { stat in
                        let level = (stat.values["audioLevel"] as? Double) ?? .zero
                        print("topic:\(topic) for call participant:\(user.callParticipant?.participant?.name ?? user.callParticipant?.participant?.username ?? "") audio level:\(level)")
                        if level > 0.01, let callParticipant = self.usersRTC.userFor(topic: topic)?.callParticipant {
                            Chat.sharedInstance.delegate?.chatEvent(event: .call(CallEventModel(type: .callParticipantStartSpeaking(callParticipant))))
                            if let index = self.usersRTC.indexFor(topic: topic) {
                                self.usersRTC[index].setUsetIsSpeaking()
                            }
                        } else if let callParticipant = self.usersRTC.userFor(topic: topic)?.callParticipant,
                                  let lastSpeakingTime = user.lastTimeSpeaking,
                                  lastSpeakingTime.timeIntervalSince1970 + 2 < Date().timeIntervalSince1970
                        {
                            Chat.sharedInstance.delegate?.chatEvent(event: .call(CallEventModel(type: .callParticipantStopSpeaking(callParticipant))))
                        }
                    }
                })
            } else {
                timer.invalidate()
            }
        }
    }

    private func createVideoTrack() -> RTCVideoTrack? {
        guard let topicVideoSend = config.topicVideoSend, let pcfSendVideo = usersRTC.userFor(topic: topicVideoSend)?.pf else {
            customPrint("topic or peerconectionfactory in createVideoTrack was nuil maybe it was audio call!", isGuardNil: true)
            return nil
        }
        let videoSource = pcfSendVideo.videoSource()
        self.videoSource = videoSource
        if TARGET_OS_SIMULATOR != 0 {
            videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        } else {
            videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        let videoTrack = pcfSendVideo.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }

    private func createAudioTrack() -> RTCAudioTrack? {
        guard let topicAudioSend = config.topicAudioSend, let mediaConstraint = usersRTC.userFor(topic: topicAudioSend)?.constraints, let pcfAudioSend = usersRTC.userFor(topic: topicAudioSend)?.pf else {
            customPrint("topic or peerconectionfactory in createAudioTrack or media constarint audio send not found!", isGuardNil: true)
            return nil
        }
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: mediaConstraint, optionalConstraints: nil)
        let audioSource = pcfAudioSend.audioSource(with: audioConstrains)
        let audioTrack = pcfAudioSend.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }

    public func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        if let capturer = videoCapturer as? RTCCameraVideoCapturer {
            guard let selectedCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }),
                  let format = getCameraFormat()
            else {
                customPrint("error happend to startCaptureLocalVideo", isGuardNil: true)
                return
            }
            customPrint("target fps :\(targetFPS)")
            DispatchQueue.global(qos: .background).async {
                capturer.startCapture(with: selectedCamera, format: format, fps: Int(self.targetFPS))
            }
            addRendererToLocalVideoTrack(renderer)
        } else if let capturer = videoCapturer as? RTCFileVideoCapturer {
            capturer.startCapturing(fromFileNamed: config.fileName ?? "", onError: { error in
                self.customPrint("error on read from mp4 file", error, isGuardNil: true)
            })
            addRendererToLocalVideoTrack(renderer)
        }
    }

    private func getCameraFormat() -> AVCaptureDevice.Format? {
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: { $0.position == (isFrontCamera ? .front : .back) }) else {
            customPrint("error to find front camera", isGuardNil: true)
            return nil
        }
        let format = RTCCameraVideoCapturer.supportedFormats(for: frontCamera).last(where: { format in
            let maxFrameRate = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate <= Float64(targetFPS) })?.maxFrameRate ?? Float64(targetFPS)
            self.targetFPS = Int32(maxFrameRate)
            return CMVideoFormatDescriptionGetDimensions(format.formatDescription).width == targetLocalVideoWidth && CMVideoFormatDescriptionGetDimensions(format.formatDescription).height == targetLocalVideoHight && Int32(maxFrameRate) <= targetFPS
        })
        return format
    }

    public func switchCameraPosition(renderer: RTCVideoRenderer) {
        if let capturer = videoCapturer as? RTCCameraVideoCapturer {
            capturer.stopCapture {
                self.isFrontCamera.toggle()
                self.startCaptureLocalVideo(renderer: renderer)
            }
        }
    }

    func addRendererToLocalVideoTrack(_ renderer: RTCVideoRenderer) {
        if let topic = config.topicVideoSend, let index = usersRTC.indexFor(topic: topic) {
            usersRTC[index].videoTrack?.add(renderer)
        }
    }

    deinit {
        customPrint("deinit webrtc client called")
    }

    func customPrint(_ message: String, _ error: Error? = nil, isSuccess: Bool = false, isGuardNil: Bool = false) {
        let errorMessage = error != nil ? " with error:\(error?.localizedDescription ?? "")" : ""
        let icon = isGuardNil ? "❌" : isSuccess ? "✅" : ""
        Chat.sharedInstance.logger?.log(title: "CHAT_SDK:\(icon)", message: "\(message) \(errorMessage)")
    }

    func saveLogsToFile() {
        if Chat.sharedInstance.config?.isDebuggingLogEnabled == true, let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let logFilePath = "WEBRTC-LOG"
            let url = dir.appendingPathComponent(logFilePath)
            customPrint("created path for log is :\(url.path)")

            logFile = RTCFileLogger(dirPath: url.path, maxFileSize: 100 * 1024)
            logFile?.severity = .info
            logFile?.start()
        }
    }

    public func updateCallParticipant(callParticipants: [CallParticipant]?) {
        if let callParticipants = callParticipants {
            callParticipants.forEach { callParticipant in
                usersRTC.filter { $0.rawTopicName == callParticipant.sendTopic }.forEach { user in
                    let index = usersRTC.firstIndex(of: user)!
                    usersRTC[index].setCallParticipant(callParticipant)
                }
            }
        }
    }
}

// MARK: - RTCPeerConnectionDelegate

public extension WebRTCClient {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        customPrint("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did add stream")
        if let videoTrack = stream.videoTracks.first, let topic = getTopicForPeerConnection(peerConnection), let renderer = usersRTC.userFor(topic: topic)?.renderer
        {
            customPrint("\(getPCName(peerConnection)) did add stream video track topic: \(topic)")
            videoTrack.add(renderer)
        }

        if let audioTrack = stream.audioTracks.first, let topic = getTopicForPeerConnection(peerConnection)
        {
            customPrint("\(getPCName(peerConnection)) did add stream audio track topic: \(topic)")
            usersRTC.userFor(topic: topic)?.pc?.add(audioTrack, streamIds: [topic])
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did remove stream")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        customPrint("\(getPCName(peerConnection)) should negotiate")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                self?.customPrint("self was nil in peerconnection didchange state", isGuardNil: true)
                return
            }
            self.customPrint("\(self.getPCName(peerConnection)) connection state changed to: \(String(describing: newState.stringValue))")
            switch newState {
            case .connected, .completed:
                self.setConnectedState(peerConnection: peerConnection)
            case .disconnected:
                self.setDisconnectedState(peerConnection: peerConnection)
            case .failed:
                self.reconnectAndGetOffer(peerConnection)
            default:
                break
            }
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: newState)
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange _: RTCIceGatheringState) {
        customPrint("\(getPCName(peerConnection)) did change new state")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let relayStr = candidate.sdp.contains("typ relay") ? "Yes ✅✅✅✅✅✅" : "No ⛔️⛔️⛔️⛔️⛔️⛔️⛔️"
        customPrint("\(getPCName(peerConnection)) did generate ICE Candidate is relayType:\(relayStr)")
        sendIceIfAnswerPresent(peerConnection, candidate)
    }

    private func sendIceIfAnswerPresent(_ peerConnection: RTCPeerConnection, _ candidate: RTCIceCandidate) {
        guard let topicName = getTopicForPeerConnection(peerConnection) else {
            customPrint("can't find topic name to send ICE Candidate", isGuardNil: true)
            return
        }
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.usersRTC.userFor(topic: topicName)?.pc?.remoteDescription != nil {
                    let sendIceCandidate = SendCandidateReq(token: Chat.sharedInstance.token ?? "",
                                                            topic: topicName,
                                                            candidate: IceCandidate(from: candidate).replaceSpaceSdpIceCandidate)
                    guard let data = try? JSONEncoder().encode(sendIceCandidate) else {
                        self.customPrint("cannot encode genereated ice to send to server!", isGuardNil: true)
                        return
                    }
                    self.customPrint("ice sended to server")
                    self.send(data)
                    timer.invalidate()
                } else {
                    let pcName = self.getPCName(peerConnection)
                    self.customPrint("answer is not present yet for \(pcName) timer will fire in 0.5 second", isGuardNil: true)
                }
            }
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
        customPrint("\(getPCName(peerConnection)) did remove candidate(s)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        customPrint("\(getPCName(peerConnection)) did open data channel \(dataChannel)")
        let topic = getPCName(peerConnection)
        var user = usersRTC.userFor(topic: topic)
        user?.dataChannel = dataChannel
    }

    private func isSendTopic(topic: String) -> Bool {
        topic == config.topicAudioSend || topic == config.topicVideoSend
    }

    private func getPCName(_ peerConnection: RTCPeerConnection) -> String {
        guard let topic = getTopicForPeerConnection(peerConnection) else { return "" }
        let isSend = isSendTopic(topic: topic)
        let isVideo = usersRTC.userFor(topic: topic)?.isVideoTopic ?? false
        return "peerConnection\(isSend ? "Send" : "Receive")\(isVideo ? "Video" : "Audio") topic:\(topic)"
    }

    private func getTopicForPeerConnection(_ peerConnection: RTCPeerConnection) -> String? {
        usersRTC.first(where: { $0.pc == peerConnection })?.topic
    }

    func setCameraIsOn(_ isCameraOn: Bool) {
        if let topicVideoSend = config.topicVideoSend, let index = usersRTC.indexFor(topic: topicVideoSend) {
            usersRTC[index].setVideo(on: isCameraOn)
        } else {
            customPrint("can not change camera state!", isGuardNil: true)
        }
    }

    func setMute(_ isMute: Bool) {
        if let topicAudioSend = config.topicAudioSend, let index = usersRTC.indexFor(topic: topicAudioSend) {
            usersRTC[index].setMute(mute: isMute)
        } else {
            customPrint("can not change micrphone state!", isGuardNil: true)
        }
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
        customPrint("data channel did changeed state to \(dataChannel.readyState)")
    }
}

// MARK: - OnReceive Message from Async Server

extension WebRTCClient {
    func messageReceived(_ message: AsyncMessage) {
        guard let content = message.content, let data = content.data(using: .utf8), let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {
            customPrint("can't decode data from webrtc servers", isGuardNil: true)
            return
        }
        customPrint("on Call message received\n\(String(data: data, encoding: .utf8) ?? "")")
        switch ms.id {
        case .sessionRefresh, .createSession, .sessionNewCreated:
            DispatchQueue.main.async {
                Chat.sharedInstance.sotpAllSignalingServerCall(peerName: self.config.peerName)
            }
        case .addIceCandidate:
            addIceToPeerConnection(data)
        case .processSdpAnswer:
            addSDPAnswerToPeerConnection(data)
        case .getKeyFrame:
            break
        case .close:
            break
        case .stopAll:
            setOffers()
        case .stop:
            break
        case .unkown:
            customPrint("a message received from unkown type form webrtc server" + (message.content ?? ""), isGuardNil: true)
        }
    }

    func addSDPAnswerToPeerConnection(_ data: Data) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                self?.customPrint("self was nil on add remote SDP Answer ", isGuardNil: true)
                return
            }
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data) else {
                self.customPrint("error decode prosessAnswer", isGuardNil: true)
                return
            }
            let pp = self.usersRTC.userFor(topic: remoteSDP.topic)?.pc
            pp?.statistics(completionHandler: { _ in
            })
            pp?.setRemoteDescription(remoteSDP.rtcSDP, completionHandler: { error in
                if let error = error {
                    self.customPrint("error in setRemoteDescroptoin with for topic:\(remoteSDP.topic) sdp: \(remoteSDP.rtcSDP)", error, isGuardNil: true)
                }
            })
        }
    }

    /// check if remote descriptoin already seted otherwise add it in to queue until set remote description then add ice to peer connection
    func addIceToPeerConnection(_ data: Data) {
        guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else {
            customPrint("error decode ice candidate received from server!", isGuardNil: true)
            return
        }

        let rtcIce = candidate.rtcIceCandidate
        guard let pp = usersRTC.userFor(topic: candidate.topic)?.pc else {
            customPrint("error finding topic or peerconnection", isGuardNil: true)
            return
        }

        if pp.remoteDescription != nil {
            setRemoteIceOnMainThread(pp, rtcIce)
        } else {
            iceQueue.append((pp, rtcIce))
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                let pcName = self.getPCName(pp)
                if pp.remoteDescription != nil {
                    self.setRemoteIceOnMainThread(pp, rtcIce)
                    self.iceQueue.remove(at: self.iceQueue.firstIndex { $0.ice == rtcIce }!)
                    self.customPrint("ICE added to \(pcName) from Queue and remaining in Queue is: \(self.iceQueue.count)")
                    timer.invalidate()
                }
            }
        }
    }

    private func setRemoteIceOnMainThread(_ peerCnnection: RTCPeerConnection, _ rtcIce: RTCIceCandidate) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            peerCnnection.add(rtcIce) { error in
                if let error = error {
                    self.customPrint("error on add ICE Candidate with ICE:\(rtcIce.sdp)", error, isGuardNil: true)
                }
            }
        }
    }
}

// configure audio session
extension WebRTCClient {
    private func configureAudioSession() {
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

    public func toggleSpeaker() {
        audioQueue.async { [weak self] in
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

public extension WebRTCClient {
    func setOffers() {
        usersRTC.forEach { userRTC in
            getOfferAndSendToPeer(topic: userRTC.topic)
        }
    }

    func getOfferAndSendToPeer(topic: String) {
        getLocalSDPWithOffer(topic: topic, onSuccess: { rtcSession in
            self.sendOfferToPeer(rtcSession, topic: topic)
        })
    }

    internal func reconnectAndGetOffer(_ peerConnection: RTCPeerConnection) {
        guard let topic = getTopicForPeerConnection(peerConnection) else {
            customPrint("can't find topic to reconnect peerconnection", isGuardNil: true)
            return
        }
        customPrint("restart to get new SDP and send offer")
        getOfferAndSendToPeer(topic: topic)
    }
}

extension Array where Element == UserRCT {
    func userFor(topic: String) -> UserRCT? {
        first(where: { $0.topic == topic })
    }

    func indexFor(topic: String) -> Int? {
        firstIndex(where: { $0.topic == topic })
    }

    mutating func removeTopic(topic: String) {
        if let index = indexFor(topic: topic) {
            self[index].pc?.close()
            remove(at: index)
        }
    }
}

enum WebRTCMessageType: String, Decodable {
    case createSession = "CREATE_SESSION"
    case sessionNewCreated = "SESSION_NEW_CREATED"
    case sessionRefresh = "SESSION_REFRESH"
    case getKeyFrame = "GET_KEY_FRAME"
    case addIceCandidate = "ADD_ICE_CANDIDATE"
    case processSdpAnswer = "PROCESS_SDP_ANSWER"
    case close = "CLOSE"
    case stopAll = "STOPALL"
    case stop = "STOP"
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
