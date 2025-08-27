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
class CallContainer: Identifiable {
    nonisolated let id: Int
    public let callId: Int
    private let debug = ProcessInfo().environment["ENABLE_CALL_CONTAINER_LOGGING"] == "1"
    
    private var cancelTimer: Timer?
    private let chat: ChatInternalProtocol
    private var state: CallState
    private var callType: CallType
    private var typeCode: String?
    private var webRTC: WebRTCClient?
    
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
        webRTC = WebRTCClient(chat: chat, config: config, callId: callId, delegate: self)
        let me = CallParticipant(sendTopic: config.topicSend ?? "", userId: userId, mute: startCall.clientDTO.mute, video: startCall.clientDTO.video, participant: .init(name: "ME"))
        var users = [me]
        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userId }.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend, userId: clientDTO.userId, mute: clientDTO.mute, video: clientDTO.video)
        }
        users.append(contentsOf: otherUsers ?? [])
        webRTC?.addCallParticipants(users)
        webRTC?.configureAudioSession()
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
    func processSDPAnswer(res: RemoteSDPRes) {
        webRTC?.callParticipntUserRCT(res.topic)?.setRemoteDescription(res)
    }
    
    func processRemoteIceCandidate(res: RemoteCandidateRes) {
        webRTC?.callParticipntUserRCT(res.topic)?.setRemoteIceCandidate(res)
    }
}

extension CallContainer: WebRTCClientDelegate {
    nonisolated func didIceConnectionStateChanged(iceConnectionState: IceConnectionState) {
        
    }
    
    nonisolated func dataChannelDidReceive(data: Data) {
        
    }
    
    nonisolated func dataChannelDidReceive(message: String) {
        
    }
    
    nonisolated func didConnectWebRTC() {
        
    }
    
    nonisolated func didDisconnectWebRTC() {
        
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
}
