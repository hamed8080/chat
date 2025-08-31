//
//  CallContainer.swift
//  Chat
//
//  Created by Hamed Hosseini on 8/26/25.
//

@preconcurrency import WebRTC
import Foundation
import Logger

@ChatGlobalActor
public class CallContainer: Identifiable {
    public nonisolated let id: Int
    public let callId: Int
    private let debug = ProcessInfo().environment["ENABLE_CALL_CONTAINER_LOGGING"] == "1"
    
    private var cancelTimer: Timer?
    private let chat: ChatInternalProtocol
    private var state: CallState
    private var callType: CallType
    private var typeCode: String?
    private var peerManager: RTCPeerConnectionManager?
    private var callParticipantsUserRTC: [CallParticipantUserRTC] = []
    
    init(callId: Int, state: CallState, callType: CallType, typeCode: String?, chat: ChatInternalProtocol) {
        id = callId
        self.callType = callType
        self.state = state
        self.callId = callId
        self.typeCode = typeCode
        self.chat = chat
    }
    
    func onCallStarted(_ startCall: StartCall) {
        state = .started
        initWebRTC(startCall)
    }
    
    private func initWebRTC(_ startCall: StartCall) {
        /// simulator File name
        let userId = chat.userInfo?.id
        let config = WebRTCConfig(callConfig: chat.config.callConfig,
                                  startCall: startCall,
                                  isSendVideoEnabled: startCall.clientDTO.video,
                                  fileName: TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil)
        peerManager = RTCPeerConnectionManager(chat: chat, config: config, callId: callId, delegate: self)
        let me = CallParticipant(sendTopic: config.topicSend ?? "",
                                 userId: userId,
                                 mute: startCall.clientDTO.mute,
                                 video: startCall.clientDTO.video,
                                 participant: .init(name: "ME"))
        var users = [me]
        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userId }.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend,
                            userId: clientDTO.userId,
                            mute: clientDTO.mute,
                            video: clientDTO.video)
        }
        users.append(contentsOf: otherUsers ?? [])
        addCallParticipants(users)
        createMediaSender()
        peerManager?.configureAudioSession()
    }
}

extension CallContainer {
    /// end call if no one doesn't accept or available to answer call
    func startTimerTimeout() {
        let config = chat.config.callConfig
        cancelTimer = Timer.scheduledTimer(withTimeInterval: config.callTimeout, repeats: false) { [weak self] _ in
            Task { @ChatGlobalActor in
                self?.onCancelTimerTriggered()
            }
        }
    }
    
    private func onCancelTimerTriggered() {
        let config = chat.config.callConfig
        log("Call has been canceled by a timer timeout after waiting \(config.callTimeout ?? 0)")
        if state == .created {
            let call = Call(id: callId,
                            creatorId: 0,
                            type: callType,
                            isGroup: false)
            let req = CancelCallRequest(call: call)
            chat.call.cancelCall(req)
        } else if state == .requested {
            chat.delegate?.chatEvent(event: .call(.callEnded(.init(result: callId, typeCode: typeCode))))
            state = .ended
        }
        cancelTimer?.invalidateTimer()
        cancelTimer = nil
    }
    
    public func createSDPOfferForLocal() {
        if let userId = chat.userInfo?.id, let myCallUser = callParticipant(id: userId) {
            Task {
                try? await peerManager?.generateSendSDPOffer(video: myCallUser.callParticipant.video == true,
                                                             topic: myCallUser.topic)
            }
        }
    }
    
    
}

extension CallContainer {
//    func processSDPAnswer(res: RemoteSDPRes) {
//        guard let topic = res.topic else { return }
//        peerManager?.callParticipntUserRCT(topic)?.setRemoteDescription(res)
//    }
//    
//    func processRemoteIceCandidate(res: RemoteCandidateRes) {
//        peerManager?.callParticipntUserRCT(res.topic)?.setRemoteIceCandidate(res)
//    }
}

extension CallContainer {
//    private func getPCName(_ peerConnection: RTCPeerConnection) -> String {
//        guard let topic = getTopicForPeerConnection(peerConnection), let callParticipant = callParticipantFor(peerConnection) else { return "" }
//        return "Peerconnection for user: \(callParticipant.callParticipant.participant?.name ?? "") with the topic:\(topic)"
//    }
//
//    private func indexOfCallParitipantFor(_ peerConnection: RTCPeerConnection) -> Array<CallParticipantUserRTC>.Index? {
//        callParticipantsUserRTC.firstIndex(where: { $0.videoRTC.pc == peerConnection || $0.audioRTC.pc == peerConnection })
//    }
//
//    private func callParticipantFor(_ peerConnection: RTCPeerConnection) -> CallParticipantUserRTC? {
//        guard let index = indexOfCallParitipantFor(peerConnection) else { return nil }
//        return callParticipantsUserRTC[index]
//    }
//
//    private func getTopicForPeerConnection(_ peerConnection: RTCPeerConnection) -> String? {
//        if let topic = callParticipantsUserRTC.first(where: { $0.audioRTC.pc == peerConnection })?.audioRTC.topic {
//            return topic
//        } else if let topic = callParticipantsUserRTC.first(where: { $0.videoRTC.pc == peerConnection })?.videoRTC.topic {
//            return topic
//        } else {
//            return nil
//        }
//    }
    
    public func addCallParticipants(_ callParticipants: [CallParticipant]) {
        callParticipants.forEach { callParticipant in
            addCallParticipant(callParticipant)
        }
    }

    /// Ordering is matter in this function.
    public func addCallParticipant(_ callParticipant: CallParticipant) {
        callParticipantsUserRTC.append(.init(chatDelegate: chat.delegate,
                                             callParticipant: callParticipant,
                                             topic: callParticipant.sendTopic,
                                             container: self))
    }

    public func createMediaSender() {
        // create media senders for both audio and video senders
        guard let myId = chat.userInfo?.id,
              let myUserRTC = callParticipant(id: myId),
              let peerManager = peerManager
        else { return }
       
        // Add audio track
        let audioTrack = peerManager.createAudioSenderTrack(topic: myUserRTC.callParticipant.topics.topicAudio)
        peerManager.addAudioTrack(audioTrack, direction: .send)
        
        // Add video track
        if myUserRTC.callParticipant.video == true {
            let videoTrack = peerManager.createVideoSenderTrack(topic: myUserRTC.callParticipant.topics.topicVideo)
            peerManager.addVideoTrack(videoTrack, direction: .send)
            peerManager.startCaptureLocalVideo(fileName: nil, front: true)
            
            Task { @MainActor in
                let view = RTCMTLVideoView(frame: .zero)
                videoTrack.add(view)
            }
        }
//        myUserRTC.addStreams()
        Task {
            //                try? await sendSDPOffers(callParticipantUserRTC: callParticipantUserRTC)
        }
    }
}

extension CallContainer: WebRTCClientDelegate {
    nonisolated public func didIceConnectionStateChanged(iceConnectionState: IceConnectionState) {
        
    }
    
    nonisolated public func dataChannelDidReceive(data: Data) {
        
    }
    
    nonisolated public func dataChannelDidReceive(message: String) {
        
    }
    
    nonisolated public func didConnectWebRTC() {
        
    }
    
    nonisolated public func didDisconnectWebRTC() {
        
    }
}

extension CallContainer {
    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "CHAT_CALL_CONTAINER", message: message, persist: false, type: .internalLog)
        }
#endif
    }
    
//    var meCallParticipntUserRCT: CallParticipantUserRTC? { callParticipantsUserRTC.first(where: { $0.isMe }) }
//    
//    func callParticipntUserRCT(_ topic: String) -> CallParticipantUserRTC? {
//        callParticipantsUserRTC.first(where: { $0.callParticipant.sendTopic == rawTopicName(topic: topic) })
//    }
//    
//    private var isPassedMaxVideoLimit: Bool {
//        callParticipantsUserRTC.filter { $0.callParticipant.video == true }.count > config.callConfig.maxActiveVideoSessions
//    }
    
    func callParticipant(id: Int) -> CallParticipantUserRTC? {
        callParticipantsUserRTC.first(where: {$0.id == id})
    }
}
