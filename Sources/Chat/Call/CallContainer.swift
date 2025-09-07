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
    public let isFrontCamera: Bool
    private var typeCode: String?
    private var peerManager: RTCPeerConnectionManager?
    public private(set) var callParticipantsUserRTC: [CallParticipantUserRTC] = []
    
    init(callId: Int, state: CallState, callType: CallType,
         typeCode: String?, isFrontCamera: Bool, chat: ChatInternalProtocol) {
        id = callId
        self.callType = callType
        self.state = state
        self.callId = callId
        self.typeCode = typeCode
        self.isFrontCamera = isFrontCamera
        self.chat = chat
    }
    
    func onCallStarted(_ startCall: StartCall) {
        state = .started
        initWebRTC(startCall)
        createSession(startCall: startCall, callId: callId)
    }
    
    func initWebRTC(_ startCall: StartCall) {
        /// simulator File name
        let userId = chat.userInfo?.id
        let config = WebRTCConfig(callConfig: chat.config.callConfig,
                                  startCall: startCall,
                                  isSendVideoEnabled: startCall.clientDTO.video,
                                  fileName: TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil)
        peerManager = RTCPeerConnectionManager(chat: chat, config: config, callId: callId)
        peerManager?.onAddVideoTrack = { @Sendable [weak self] videoTrack, mid in
            Task {
                await self?.onVideoTrackAdded(videoTrack: videoTrack, mid: mid)
            }
        }
        
        peerManager?.onAddAudioTrack = { @Sendable [weak self] audioTrack, mid in
            Task {
                await self?.onAudioTrackAdded(audioTrack: audioTrack, mid: mid)
            }
        }
        let users = startCall.otherClientDtoList?.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend,
                            userId: clientDTO.userId,
                            clientId: clientDTO.clientId,
                            mute: clientDTO.mute,
                            video: clientDTO.video)
        } ?? []
        addCallParticipants(users)

    }
    
    func createSession(startCall: StartCall, callId: Int) {
        peerManager?.createSession(startCall: startCall, callId: callId)
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
}

extension CallContainer {
    func processSDPAnswer(_ res: RemoteSDPAnswerRes) {
        peerManager?.processSDPAnswer(res)
    }
    
    func setPeerIceCandidate(_ res: AddIceCandidateRes, _ direction: RTCDirection) {
        peerManager?.setPeerIceCandidate(ice: res.candidate, direction: direction)
    }
    
    func processSDPOffer(_ res: RemoteSDPOfferRes) {
        peerManager?.processSDPOffer(res)
        for addition in res.addition {
            if let clientId = addition.clientId,
               let user = callParticipant(clientId: clientId),
               let mids = addition.mids
            {
                user.addMids(topic: addition.topic, mids: mids)
            }
        }
    }
    
    func createSDPOfferForLocal() {
        if let userId = chat.userInfo?.id, let myCallUser = callParticipant(userId: userId) {
            peerManager?.sendTracksQueue.startOpening(myCallUser)
        }
    }
}

extension CallContainer {
    
    public func addCallParticipants(_ callParticipants: [CallParticipant]) {
        callParticipants.forEach { callParticipant in
            addCallParticipant(callParticipant)
        }
    }

    /// Ordering is matter in this function.
    public func addCallParticipant(_ callParticipant: CallParticipant) {
        let userRTC = CallParticipantUserRTC(
            callParticipant: callParticipant,
            topic: callParticipant.sendTopic,
            container: self
        )
        callParticipantsUserRTC.append(userRTC)
    }
    
    func subscribeToReceiveOffers(_ media: ReceivingMedia) {
        peerManager?.subscribeToReceiveOffers(media)
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
    
    //    private var isPassedMaxVideoLimit: Bool {
    //        callParticipantsUserRTC.filter { $0.callParticipant.video == true }.count > config.callConfig.maxActiveVideoSessions
    //    }
    
    func callParticipant(clientId: Int) -> CallParticipantUserRTC? {
        callParticipantsUserRTC.first(where: {$0.id == clientId})
    }
    
    func callParticipant(userId: Int) -> CallParticipantUserRTC? {
        callParticipantsUserRTC.first(where: {$0.callParticipant.userId == userId})
    }
    
    public func dispose() {
        peerManager?.dispose()
    }
}

// MARK: Track management

extension CallContainer {
    private func onVideoTrackAdded(videoTrack: RTCVideoTrack, mid: String) {
        guard
            let user = self.callParticipantsUserRTC.first(where: { $0.topic(for: mid) != nil }),
            let clientId = user.callParticipant.clientId
        else { return }
        
        user.videoTrack = videoTrack
        self.chat.delegate?.chatEvent(event: .call(.videoTrackAdded(videoTrack, clientId)))
    }
    
    private func onAudioTrackAdded(audioTrack: RTCAudioTrack, mid: String) {
        guard
            let user = self.callParticipantsUserRTC.first(where: { $0.topic(for: mid) != nil }),
            let clientId = user.callParticipant.clientId
        else { return }
        
        user.audioTrack = audioTrack
        self.chat.delegate?.chatEvent(event: .call(.audioTrackAdded(audioTrack, clientId)))
    }
}

// MARK: Chat server events handlers.

extension CallContainer {
    func handleVideoChange(on: Bool, _ resp: ChatResponse<[CallParticipant]>) {
        for participant in resp.result ?? [] {
            if let userId = participant.userId, let userRTC = callParticipant(userId: userId) {
                userRTC.callParticipant.video = on
                userRTC.videoTrack?.isEnabled = on
            }
        }
    }
    
    func handleMuteChange(mute: Bool, _ resp: ChatResponse<[CallParticipant]>) {
        for participant in resp.result ?? [] {
            if let userId = participant.userId, let userRTC = callParticipant(userId: userId) {
                userRTC.callParticipant.mute = mute
                userRTC.audioTrack?.isEnabled = !mute
            }
        }
    }
}

// MARK: Actions

extension CallContainer {
    func setSpeaker(on: Bool) {
        peerManager?.setSpeaker(on: on)
    }
}
