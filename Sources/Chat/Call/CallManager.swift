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

final class CallManager: CallProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var callParticipantsUserRTC: [CallParticipantUserRTC] = []
    
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
    
    /// Only call on receivers side. The starter of call never get this event.
    func onStartCall(_ asyncMessage: AsyncMessage) {
//        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
//        delegate?.chatEvent(event: .call(.callReceived(response)))
//        ChatCall.instance?.callState = .requested
//        startTimerTimeout(callId: response.result?.callId ?? 0)
//        // SEND type 73 . This mean client receive call and showing ringing mode on call creator.
//        callReceived(.init(subjectId: response.result?.callId ?? 0))
    }

    func onCallStarted(_ asyncMessage: AsyncMessage) {
//        var response: ChatResponse<StartCall> = asyncMessage.toChatResponse()
//        response.result?.callId = response.subjectId
//        ChatCall.instance?.callState = .started
//        if let callStarted = response.result {
//            initWebRTC(callStarted)
//        }
//        delegate?.chatEvent(event: .call(.callStarted(response)))
    }

    // Only public for swiftui Preview
    public func initWebRTC(_ startCall: StartCall) {
//        /// simulator File name
//        let smFileName = TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil
//        let config = WebRTCConfig(callConfig: config.callConfig, startCall: startCall, isSendVideoEnabled: startCall.clientDTO.video, fileName: smFileName)
//        ChatCall.instance?.webrtc = WebRTCClient(chat: self, config: config, delegate: callDelegate)
//        let me = CallParticipant(sendTopic: config.topicSend ?? "", userId: userInfo?.id, mute: startCall.clientDTO.mute, video: startCall.clientDTO.video, participant: .init(name: "ME"))
//        var users = [me]
//        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userInfo?.id }.compactMap { clientDTO in
//            CallParticipant(sendTopic: clientDTO.topicSend, userId: clientDTO.userId, mute: clientDTO.mute, video: clientDTO.video)
//        }
//        users.append(contentsOf: otherUsers ?? [])
//        ChatCall.instance?.webrtc?.addCallParticipants(users)
//        ChatCall.instance?.webrtc?.createSession()
    }

    func onDeliverCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callDelivered(response)))
    }

    /// maybe starter of call after start call request disconnected we need to close ui on the receiver side
    func startTimerTimeout(callId: Int) {
//        _ = ChatCall.instance?.callStartTimer?.scheduledTimer(interval: config.callConfig.callTimeout, repeats: false) { [weak self] timer in
//            // If the user clicks on reject button the chat.callStatus = .cacnceled and bottom code will not be executed.
//            if ChatCall.instance?.callState == .requested {
//                let message = "Call has been canceled by a timer timeout after waiting \(self?.config.callConfig.callTimeout ?? 0)"
//                self?.logger.log(title: "ChatCall", message: message, persist: false, type: .internalLog)
//                self?.delegate?.chatEvent(event: .call(.callEnded(.init(result: callId))))
//                ChatCall.instance?.callState = .ended
//            }
//            timer.invalidateTimer()
//        }
    }

    func onCallSessionCreated(_ asyncMessage: AsyncMessage) {
//        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
//        delegate?.chatEvent(event: .call(.callCreate(response)))
//        ChatCall.instance?.callState = .created
//        if let createCall = response.result {
//            startTimerTimeout(createCall)
//        }
    }

    /// end call if no one doesn't accept or available to answer call
    func startTimerTimeout(_ createCall: CreateCall) {
//        _ = ChatCall.instance?.callStartTimer?.scheduledTimer(interval: config.callConfig.callTimeout, repeats: false) { [weak self] timer in
//            if ChatCall.instance?.callState == .created {
//                let message = "Call has been canceled by a timer timeout after waiting \(self?.config.callConfig.callTimeout ?? 0)"
//                self?.logger.log(title: "ChatCall", message: message, persist: false, type: .internalLog)
//                let call = Call(id: createCall.callId,
//                                creatorId: 0,
//                                type: createCall.type,
//                                isGroup: false)
//                let req = CancelCallRequest(call: call)
//                self?.cancelCall(req)
//            }
//            timer.invalidateTimer()
//        }
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
