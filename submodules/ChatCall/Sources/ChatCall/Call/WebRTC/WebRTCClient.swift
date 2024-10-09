//
// CallParticipantUserRTCProtocol.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Darwin
import Chat
import Foundation
import WebRTC
import ChatCore
import ChatModels
import Async

public protocol CallParticipantUserRTCProtocol {
    init(chatDelegate: ChatDelegate?, userId: Int?, callParticipant: CallParticipant, config: WebRTCConfig, delegate: RTCPeerConnectionDelegate)
    var callParticipant: CallParticipant { get set }
    var audioRTC: AudioRTC { get set }
    var videoRTC: VideoRTC { get set }
    var userId: Int? { get set }
    var isMe: Bool { get }
    func peerConnectionForTopic(topic: String) -> RTCPeerConnection?
    func uerRTC(topic: String) -> UserRTCProtocol?
    func createMediaSenderTracks(_ fileName: String?)
    func addStreams()
    func toggleMute()
    func toggleCamera()
    func switchCameraPosition()
    func addIceCandidate(_ candidate: RemoteCandidateRes)
    func setRemoteDescription(_ remoteSDP: RemoteSDPRes)
    func close()
}

// MARK: - Pay attention, this class use many extensions inside a files not be here.

public class WebRTCClient: NSObject, RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    private var chat: ChatInternalProtocol?
    private var answerReceived: [String: RTCPeerConnection] = [:]
    private var config: WebRTCConfig
    private var delegate: WebRTCClientDelegate?
    public private(set) var callParticipantsUserRTC: [CallParticipantUserRTC] = []
    var logFile: RTCFileLogger?
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private var isPassedMaxVideoLimit: Bool { callParticipantsUserRTC.filter { $0.callParticipant.video == true }.count > config.callConfig.maxActiveVideoSessions }

    public init(chat: ChatInternalProtocol, config: WebRTCConfig, delegate: WebRTCClientDelegate? = nil) {
        self.chat = chat
        self.config = config
        self.delegate = delegate
        RTCInitializeSSL()
        super.init()
        ChatCall.instance?.callState = .initializeWebrtc
        if self.chat?.config.callConfig.logWebRTC == true {
            print(config)
            // Console output
            RTCSetMinDebugLogLevel(RTCLoggingSeverity.info)
            // File output
            saveLogsToFile()
        }
    }

    public func createSession() {
        configureAudioSession()
        let session = CreateSessionReq(peerName: config.peerName, turnAddress: config.turnAddress, brokerAddress: config.brokerAddressWeb, token: chat?.config.token ?? "")
        send(session)
    }

    /// Ordering is matter in this function.
    public func addCallParticipant(_ callParticipant: CallParticipant) {
        callParticipantsUserRTC.append(.init(chatDelegate: chat?.delegate, userId: chat?.userInfo?.id, callParticipant: callParticipant, config: config, delegate: self))
        // create media senders for both audio and video senders

        if let callParticipantUserRTC = callParticipantsUserRTC.first(where: { $0.callParticipant == callParticipant }) {
            callParticipantUserRTC.createMediaSenderTracks(config.fileName)
            callParticipantUserRTC.addStreams()
            callParticipantUserRTC.getAudioOffer(sendOfferToPeer)
            callParticipantUserRTC.getVideoOffer(sendOfferToPeer)
        }
    }

    public func addCallParticipants(_ callParticipants: [CallParticipant]) {
        callParticipants.forEach { callParticipant in
            addCallParticipant(callParticipant)
        }
        reCalculateActiveVideoSessionLimit()
    }

    /// If it has passed ``CallConfig/maxActiveVideoSessions``, then find the first active video and disable it, and send an event to client for updating the view.
    /// If it sees that the limitation is not passed, it will return to active all inactive video sessions.
    public func reCalculateActiveVideoSessionLimit() {
        if isPassedMaxVideoLimit, let topActive = callParticipantsUserRTC.first(where: { $0.callParticipant.video == true }) {
            deActiveFirstVideoSession(topActive)
        } else {
            reActiveVideoSession()
        }
    }

    private func deActiveFirstVideoSession(_ callParticipant: CallParticipantUserRTC) {
        callParticipant.videoRTC.setTrackEnable(false)
        chat?.delegate?.chatEvent(event: .call(.maxVideoSessionLimit(.init(uniqueId: nil, result: callParticipant.callParticipant, time: Int(Date().timeIntervalSince1970)))))
    }

    private func reActiveVideoSession() {
        callParticipantsUserRTC.filter { $0.callParticipant.video == true && $0.videoRTC.isVideoTrackEnable == false }.forEach { callParticipant in
            callParticipant.videoRTC.setTrackEnable(true)
            chat?.delegate?.chatEvent(event: .call(.maxVideoSessionLimit(.init(uniqueId: nil, result: callParticipant.callParticipant, time: Int(Date().timeIntervalSince1970)))))
        }
    }

    public func removeCallParticipant(_ callParticipant: CallParticipant) {
        if let index = callParticipantsUserRTC.firstIndex(where: { $0.callParticipant.userId == callParticipant.userId }) {
            callParticipantsUserRTC[index].close()
            callParticipantsUserRTC.remove(at: index)
        }
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
        callParticipantsUserRTC.forEach { callParticipantUserRTC in
            if let index = callParticipantsUserRTC.firstIndex(where: { $0 == callParticipantUserRTC }) {
                callParticipantsUserRTC[index].close()
            }
        }
        destroyAudioSession()
        let close = CloseSessionReq(peerName: config.peerName, token: chat?.config.token ?? "")
        send(close)
        logFile?.stop()
        callParticipantsUserRTC = []
    }

    public func sendOfferToPeer(idType: String, _ sdp: RTCSessionDescription, topic: String, mediaType: Mediatype) {
        let sendSDPOffer = SendOfferSDPReq(peerName: config.peerName,
                                           id: idType,
                                           brokerAddress: config.firstBorokerAddressWeb,
                                           token: chat?.config.token ?? "",
                                           topic: topic,
                                           sdpOffer: sdp.sdp,
                                           mediaType: mediaType,
                                           chatId: config.callId)
        send(sendSDPOffer)
    }

    func send(_ asyncMessage: AsyncSnedable) {
        guard let config = chat?.config, let content = asyncMessage.content else { return }
        let asyncMessage = SendAsyncMessageVO(content: content,
                                              ttl: config.msgTTL,
                                              peerName: asyncMessage.peerName ?? config.asyncConfig.peerName,
                                              priority: config.msgPriority,
                                              uniqueId: (asyncMessage as? AsyncChatServerMessage)?.chatMessage.uniqueId)
        guard chat?.state == .chatReady || chat?.state == .asyncReady else { return }
        chat?.logger.logJSON(title: "ChatCall",jsonString: asyncMessage.string ?? "", persist: false, type: .sent)
        chat?.asyncManager.asyncClient?.send(message: asyncMessage)
    }

    deinit {
        customPrint("deinit webrtc client called")
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
}

// MARK: - RTCPeerConnectionDelegate

public extension WebRTCClient {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        customPrint("\(getPCName(peerConnection))  signaling state changed: \(String(describing: stateChanged.stringValue))")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        customPrint("\(getPCName(peerConnection)) did add stream")
        if let callParticipntUserRCT = callParticipantFor(peerConnection) {
            if let videoTrack = stream.videoTracks.first, let topic = getTopicForPeerConnection(peerConnection), let renderer = callParticipntUserRCT.videoRTC.renderer {
                customPrint("\(getPCName(peerConnection)) did add stream video track topic: \(topic)")
                videoTrack.add(renderer)
            }

            if let audioTrack = stream.audioTracks.first, let topic = getTopicForPeerConnection(peerConnection) {
                customPrint("\(getPCName(peerConnection)) did add stream audio track topic: \(topic)")
                callParticipntUserRCT.audioRTC.pc?.add(audioTrack, streamIds: [topic])
            }
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
            self.delegate?.didIceConnectionStateChanged(iceConnectionState: IceConnectionState(rawValue: newState.rawValue))
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange _: RTCIceGatheringState) {
        customPrint("\(getPCName(peerConnection)) did change new state")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let relayStr = candidate.sdp.contains("typ relay") ? "Yes ✅✅✅✅✅✅" : "No ⛔️⛔️⛔️⛔️⛔️⛔️⛔️"
        customPrint("\(getPCName(peerConnection)) did generate ICE Candidate is relayType:\(relayStr)")
        guard let topicName = getTopicForPeerConnection(peerConnection) else {
            customPrint("can't find topic name to send ICE Candidate", isGuardNil: true)
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.recursiveTimerForRemoteSDP(0.5, topicName, candidate, peerConnection)
        }
    }

    private func recursiveTimerForRemoteSDP(_ interval: TimeInterval, _ topicName: String, _ candidate: RTCIceCandidate, _ peerConnection: RTCPeerConnection, _ retryCount: Int = 0) {
        let intervals: [Int] = [2, 4, 8, 12]
        if retryCount > intervals.count - 1 { return }
        let nextInterval = TimeInterval(intervals[retryCount])
        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.callParticipntUserRCT(topicName)?.peerConnectionForTopic(topic: topicName)?.remoteDescription != nil {
                let sendIceCandidate = SendCandidateReq(peerName: self.config.peerName,
                                                        token: self.chat?.config.token ?? "",
                                                        topic: topicName,
                                                        candidate: IceCandidate(from: candidate).replaceSpaceSdpIceCandidate)
                self.customPrint("ice sended to server")
                self.send(sendIceCandidate)
            } else {
                self.recursiveTimerForRemoteSDP(nextInterval, topicName, candidate, peerConnection, retryCount + 1)
                let pcName = self.getPCName(peerConnection)
                self.customPrint("answer is not present yet for \(pcName) timer will fire in \(nextInterval) second", isGuardNil: true)
            }
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {
        customPrint("\(getPCName(peerConnection)) did remove candidate(s)")
    }

    func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}

    private func isSendTopic(topic: String) -> Bool {
        topic == config.topicAudioSend || topic == config.topicVideoSend
    }

    private func getPCName(_ peerConnection: RTCPeerConnection) -> String {
        guard let topic = getTopicForPeerConnection(peerConnection), let callParticipant = callParticipantFor(peerConnection) else { return "" }
        return "Peerconnection for user: \(callParticipant.callParticipant.participant?.name ?? "") with the topic:\(topic)"
    }

    private func indexOfCallParitipantFor(_ peerConnection: RTCPeerConnection) -> Array<CallParticipantUserRTC>.Index? {
        callParticipantsUserRTC.firstIndex(where: { $0.videoRTC.pc == peerConnection || $0.audioRTC.pc == peerConnection })
    }

    private func callParticipantFor(_ peerConnection: RTCPeerConnection) -> CallParticipantUserRTC? {
        guard let index = indexOfCallParitipantFor(peerConnection) else { return nil }
        return callParticipantsUserRTC[index]
    }

    private func getTopicForPeerConnection(_ peerConnection: RTCPeerConnection) -> String? {
        if let topic = callParticipantsUserRTC.first(where: { $0.audioRTC.pc == peerConnection })?.audioRTC.topic {
            return topic
        } else if let topic = callParticipantsUserRTC.first(where: { $0.videoRTC.pc == peerConnection })?.videoRTC.topic {
            return topic
        } else {
            return nil
        }
    }

    func toggleCamera() {
        meCallParticipntUserRCT?.toggleCamera()
    }

    func toggle() {
        meCallParticipntUserRCT?.toggleMute()
    }

    func switchCamera() {
        meCallParticipntUserRCT?.switchCameraPosition()
    }

    var meCallParticipntUserRCT: CallParticipantUserRTC? { callParticipantsUserRTC.first(where: { $0.isMe }) }

    func callParticipntUserRCT(_ topic: String) -> CallParticipantUserRTC? {
        callParticipantsUserRTC.first(where: { $0.callParticipant.sendTopic == rawTopicName(topic: topic) })
    }

    func rawTopicName(topic: String) -> String {
        topic.replacingOccurrences(of: "Vi-", with: "").replacingOccurrences(of: "Vo-", with: "")
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
    func onCallMessageReceived(_ message: AsyncMessage) {
        guard let content = message.content, let data = content.data(using: .utf8), let ms = try? JSONDecoder().decode(WebRTCAsyncMessage.self, from: data) else {
            customPrint("can't decode data from webrtc servers", isGuardNil: true)
            return
        }
        customPrint("on Call message received\n\(String(data: data, encoding: .utf8) ?? "")")
        switch ms.id {
        case .sessionRefresh, .createSession, .sessionNewCreated:
            stopAllSessions()
        case .addIceCandidate:
            guard let candidate = try? JSONDecoder().decode(RemoteCandidateRes.self, from: data) else {
                print("error decode ice candidate")
                return
            }
            callParticipntUserRCT(candidate.topic)?.addIceCandidate(candidate)
        case .processSdpAnswer:
            guard let remoteSDP = try? JSONDecoder().decode(RemoteSDPRes.self, from: data) else {
                print("error decode prosessAnswer")
                return
            }
            callParticipntUserRCT(remoteSDP.topic)?.setRemoteDescription(remoteSDP)
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

    func stopAllSessions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let stop = StopAllSessionReq(peerName: self.config.peerName, token: self.chat?.config.token ?? "")
            self.send(stop)
        }
    }
}

// configure audio session
public extension WebRTCClient {
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

    func toggleSpeaker() {
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

    func destroyAudioSession() {
        audioQueue.async { [weak self] in
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

public extension WebRTCClient {
    func setOffers() {
        callParticipantsUserRTC.forEach { callParticipantUserRTC in
            callParticipantUserRTC.getAudioOffer(sendOfferToPeer)
            callParticipantUserRTC.getVideoOffer(sendOfferToPeer)
        }
    }

    internal func reconnectAndGetOffer(_ peerConnection: RTCPeerConnection) {
        guard let callParticipantuserRTC = callParticipantFor(peerConnection) else {
            customPrint("can't find topic to reconnect peerconnection", isGuardNil: true)
            return
        }
        callParticipantuserRTC.getVideoOffer(sendOfferToPeer)
        callParticipantuserRTC.getAudioOffer(sendOfferToPeer)
    }
}

