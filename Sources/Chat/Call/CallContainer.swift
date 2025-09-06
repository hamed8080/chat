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
    
    func onCallStarted(_ startCall: StartCall) async {
        state = .started
        await initWebRTC(startCall)
    }
    
    private func initWebRTC(_ startCall: StartCall) async {
        /// simulator File name
        let userId = chat.userInfo?.id
        let config = WebRTCConfig(callConfig: chat.config.callConfig,
                                  startCall: startCall,
                                  isSendVideoEnabled: startCall.clientDTO.video,
                                  fileName: TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil)
        peerManager = RTCPeerConnectionManager(chat: chat, config: config, callId: callId)
        peerManager?.onAddVideoTrack = { @Sendable [weak self] videoTrack, mid in
            Task { @ChatGlobalActor in
                let user = self?.callParticipantsUserRTC.first(where: { $0.topic(for: mid) != nil })
                print("user to set renderer is:", user?.callParticipant.participant?.name)
                if let renderer = await user?.renderer {
                    videoTrack.add(renderer)
                }
            }
        }
        let me = CallParticipant(sendTopic: config.topicSend ?? "",
                                 userId: userId,
                                 mute: startCall.clientDTO.mute,
                                 video: startCall.clientDTO.video,
                                 participant: .init(name: "ME"))
        var users = [me]
        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userId }.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend,
                            userId: clientDTO.userId,
                            clientId: clientDTO.clientId,
                            mute: clientDTO.mute,
                            video: clientDTO.video)
        }
        users.append(contentsOf: otherUsers ?? [])
        addCallParticipants(users)
        
        for var user in callParticipantsUserRTC {
            await user.createRenderer()
        }
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
        if let userId = chat.userInfo?.id, let myCallUser = callParticipant(userId: userId) {
            Task {
                let isVideo = myCallUser.callParticipant.video == true
                let topics = myCallUser.callParticipant.topics
                let topic = isVideo ? topics.topicVideo : topics.topicAudio
                try? await peerManager?.generateSDPOffer(video: isVideo,
                                                         topic: topic,
                                                         direction: .send
                )
            }
        }
    }
}

extension CallContainer {
    func processSDPAnswer(_ res: RemoteSDPAnswerRes) {
        peerManager?.setRemoteDescription(res, direction: .send)
    }
//    
//    func processRemoteIceCandidate(res: RemoteCandidateRes) {
//        peerManager?.callParticipntUserRCT(res.topic)?.setRemoteIceCandidate(res)
//    }
    
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
}

extension CallContainer {
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

    public func createMediaSender() {
        // create media senders for both audio and video senders
        guard let myId = chat.userInfo?.id,
              let myUserRTC = callParticipant(userId: myId),
              let peerManager = peerManager
        else { return }
       
        // Add audio track
        let audioTrack = peerManager.createAudioSenderTrack()
        peerManager.addAudioTrack(audioTrack, direction: .send)
        
        // Add video track
        if myUserRTC.callParticipant.video == true {
            let videoTrack = peerManager.createVideoSenderTrack()
            peerManager.addVideoTrack(videoTrack, direction: .send)
            peerManager.startCaptureLocalVideo(fileName: nil, front: isFrontCamera)
            
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
    
    //    var meCallParticipntUserRCT: CallParticipantUserRTC? { callParticipantsUserRTC.first(where: { $0.isMe }) }
    //    
    //    func callParticipntUserRCT(_ topic: String) -> CallParticipantUserRTC? {
    //        callParticipantsUserRTC.first(where: { $0.callParticipant.sendTopic == rawTopicName(topic: topic) })
    //    }
    //    
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
