//
// ReactionManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import ChatExtensions
import WebRTC

final class CallManager: CallProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var callParticipantsUserRTC: [CallParticipantUserRTC] = []
    private var callContainers: [CallContainer] = []
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func acceptCall(_ request: AcceptCallRequest) {
        
    }
    
    func activeCallParticipants(_ request: GeneralSubjectIdRequest) {
       
    }
    
    func addCallPartcipant(_ request: AddCallParticipantsRequest) {
        
    }
    
    func callInquery(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func startRecording(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func stopRecording(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func callsHistory(_ request: CallsHistoryRequest) {
        
    }
    
    func sendCallSticker(_ request: CallStickerRequest) {
        
    }
    
    func getCallsToJoin(_ request: GetJoinCallsRequest) {
        
    }
    
    func cancelCall(_ request: CancelCallRequest) {
        
    }
    
    func muteCall(_ request: MuteCallRequest) {
        
    }
    
    func unmuteCall(_ request: UNMuteCallRequest) {
        
    }
    
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func endCall(_ request: ChatDTO.GeneralSubjectIdRequest) {
        
    }
    
    func removeCallPartcipant(_ request: RemoveCallParticipantsRequest) {
        
    }
    
    func renewCallRequest(_ request: RenewCallRequest) {
        
    }
    
    func sendCallClientError(_ request: CallClientErrorRequest) {
        
    }
    
    func requestCall(_ request: StartCallRequest) {
        chat.prepareToSendAsync(req: request, type: .startCallRequest)
    }
    
    func requestGroupCall(_ request: StartCallRequest) {
        
    }
    
    func terminateCall(_ request: GeneralSubjectIdRequest) {
        
    }
    
    func preview(startCall: ChatDTO.StartCall) {
        
    }
    
    func switchCamera() {
        
    }
    
    func toggleSpeaker() {
        
    }
    
    func reCalculateActiveVideoSessionLimit() {
        
    }
    
    func turnOffVideoCall(callId: Int) {
        
    }
    
    func turnOnVideoCall(callId: Int) {
        
    }
    
    func addCallParticipants(_ callParticipants: [ChatModels.CallParticipant]) {
        
    }
}

/// Server Responses
extension CallManager {
    func onActiveCallParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.activeCallParticipants(response)))
    }
    
    func onJoinCallParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantJoined(response)))
    }
    
    func onCallInquiry(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callInquery(response)))
    }
    
    func onCallRecordingStarted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.startCallRecording(response)))
    }

    func onCallRecordingStopped(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.stopCallRecording(response)))
    }
    
    func onCallsHistory(_ asyncMessage: AsyncMessage) {
//        var response: ChatResponse<[Call]> = asyncMessage.toChatResponse(asyncManager: asyncManager)
//        response.contentCount = asyncMessage.chatMessage?.contentCount
//        delegate?.chatEvent(event: .call(.history(response)))
    }
    
    func onCallSticker(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<StickerResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.sticker(response)))
    }
    
    func onJoinCalls(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Call]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callsToJoin(response)))
    }
    
    func onCancelCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callCanceled(response)))
    }

    func onGroupCallCanceled(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<CancelGroupCall> = asyncMessage.toChatResponse()
        response.result?.callId = response.subjectId
        delegate?.chatEvent(event: .call(.groupCallCanceled(response)))
    }
    
    func onMute(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantMute(response)))
    }

    func onUNMute(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantUnmute(response)))
    }
    
    func onVideoTurnedOn(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.turnVideoOn(response)))
    }

    func onVideoTurnedOff(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.turnVideoOff(response)))
    }
    
    func onCallEnded(_ asyncMessage: AsyncMessage) {
//        var response: ChatResponse<Int> = asyncMessage.toChatResponse()
//        ChatCall.instance?.callState = .ended
//        response.result = response.subjectId
//        delegate?.chatEvent(event: .call(.callEnded(response)))
//        ChatCall.instance?.webrtc?.clearResourceAndCloseConnection()
//        ChatCall.instance?.webrtc = nil
    }
    
    func onRemoveCallParticipant(_ asyncMessage: AsyncMessage) {
//        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
//        delegate?.chatEvent(event: .call(.callParticipantsRemoved(response)))
//        response.result?.forEach { callParticipant in
//            ChatCall.instance?.webrtc?.removeCallParticipant(callParticipant)
//            if callParticipant.userId == userInfo?.id {
//                ChatCall.instance?.webrtc?.clearResourceAndCloseConnection()
//            }
//        }
    }
    
    func onRenewCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.renewCall(response)))
    }
    
    func onCallError(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CallError> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callError(response)))
    }
    
    /// This method will only be called on the receiver’s side.
    /// The starter of this call will never get this event.
    func onCallRequest(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callReceived(response)))
        
        if let res = response.result {
            let callContainer = makeCallContainer(createCall: res, for: .requested, typeCode: response.typeCode)
            self.callContainers.append(callContainer)
            callContainer.startTimerTimeout()
        }
        
        // SEND type 73 . This mean client receive call and showing ringing mode on call creator.
//        callReceived(.init(subjectId: response.result?.callId ?? 0))
    }

    func onCallStarted(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<StartCall> = asyncMessage.toChatResponse()
        if let callStarted = response.result,
           let container = callContainers.first(where: {$0.callId == response.subjectId})
        {
            container.onCallStarted(callStarted)
        }
        delegate?.chatEvent(event: .call(.callStarted(response)))
    }

    func onDeliverCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callDelivered(response)))
    }

    func onCallSessionCreated(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callCreate(response)))
        
        if let res = response.result {
            let callContainer = makeCallContainer(createCall: res, for: .created, typeCode: response.typeCode)
            self.callContainers.append(callContainer)
            callContainer.startTimerTimeout()
        }
    }

    func onCallParticipantLeft(_ asyncMessage: AsyncMessage) {
//        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
//        delegate?.chatEvent(event: .call(.callParticipantLeft(response)))
//        response.result?.forEach { callParticipant in
//            ChatCall.instance?.webrtc?.removeCallParticipant(callParticipant)
//            if callParticipant.userId == userInfo?.id {
//                ChatCall.instance?.webrtc?.clearResourceAndCloseConnection()
//            }
//        }
    }

    func onRejectCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callRejected(response)))
    }
    
}

extension CallManager {
    private func makeCallContainer(createCall: CreateCall, for state: CallState, typeCode: String?) -> CallContainer {
        return CallContainer(callId: createCall.callId,
                                          state: state,
                                          callType: createCall.type,
                                          typeCode: typeCode,
                                          chat: chat)
    }
}

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
    
    // Only public for swiftui Preview
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
        webRTC?.createSession()
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

extension CallContainer: WebRTCClientDelegate {
    nonisolated func didIceConnectionStateChanged(iceConnectionState: IceConnectionState) {
        
    }
    
    nonisolated func didReceiveData(data: Data) {
        
    }
    
    nonisolated func didReceiveMessage(message: String) {
        
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
