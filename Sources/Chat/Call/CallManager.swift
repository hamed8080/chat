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

final class CallManager: CallProtocol, InternalCallProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    private var callContainers: [CallContainer] = []
    private var isFrontCamera: Bool = true
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }
    
    func acceptCall(_ request: AcceptCallRequest) {
        chat.prepareToSendAsync(req: request, type: .acceptCall)
    }
    
    func activeCallParticipants(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .activeCallParticipants)
    }
    
    func addCallPartcipant(_ request: AddCallParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .addCallParticipant)
    }
    
    func removeCallPartcipant(_ request: RemoveCallParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .removeCallParticipant)
    }
    
    func callInquery(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .callInquiry)
    }
    
    func startRecording(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .startRecording)
    }
    
    func stopRecording(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .stopRecording)
    }
    
    func callsHistory(_ request: CallsHistoryRequest) {
        chat.prepareToSendAsync(req: request, type: .getCalls)
    }
    
    func sendCallSticker(_ request: CallStickerRequest) {
        chat.prepareToSendAsync(req: request, type: .callStickerSystemMessage)
    }
    
    func callsToJoin(_ request: GetJoinCallsRequest) {
        chat.prepareToSendAsync(req: request, type: .getCallsToJoin)
    }
    
    func cancelCall(_ request: CancelCallRequest) {
        chat.prepareToSendAsync(req: request, type: .cancelCall)
    }
    
    func muteCallParticipants(_ request: MuteCallParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .muteCallParticipant)
    }
    
    func unmuteCallParticipants(_ request: UNMuteCallParitcipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .unmuteCallParticipant)
    }
    
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .turnOnVideoCall)
    }
    
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .turnOffVideoCall)
    }
    
    func endCall(_ request: ChatDTO.GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .endCallRequest)
    }
    
    func renewCallRequest(_ request: RenewCallRequest) {
        chat.prepareToSendAsync(req: request, type: .renewCallRequest)
    }
    
    func sendCallClientError(_ request: CallClientErrorRequest) {
        chat.prepareToSendAsync(req: request, type: .callClientErrors)
    }
    
    func requestCall(_ request: StartCallRequest) {
        isFrontCamera = request.isFrontCamera
        chat.prepareToSendAsync(req: request, type: .startCallRequest)
    }
    
    func requestGroupCall(_ request: StartCallRequest) {
        chat.prepareToSendAsync(req: request, type: .groupCallRequest)
    }
    
    func terminateCall(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .terminateCall)
    }
    
    func preview(startCall: StartCall) {}
    
    func switchCamera() {
        
    }
    
    func setSpeaker(on: Bool, callId: Int) {
        if let container = callContainer(callId: callId) {
            container.setSpeaker(on: on)
        }
    }
    
    func reCalculateActiveVideoSessionLimit() {
        
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
        var response: ChatResponse<[Call]> = asyncMessage.toChatResponse()
        response.contentCount = asyncMessage.chatMessage?.contentCount
        delegate?.chatEvent(event: .call(.history(response)))
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
        if let callId = response.subjectId, let container = callContainer(callId: callId) {
            container.handleMuteChange(mute: true, response)
        }
        delegate?.chatEvent(event: .call(.callParticipantMute(response)))
    }
    
    func onUNMute(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        if let callId = response.subjectId, let container = callContainer(callId: callId) {
            container.handleMuteChange(mute: false, response)
        }
        delegate?.chatEvent(event: .call(.callParticipantUnmute(response)))
    }
    
    func onVideoTurnedOn(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        if let callId = response.subjectId, let container = callContainer(callId: callId) {
            container.handleVideoChange(on: true, response)
        }
        delegate?.chatEvent(event: .call(.turnVideoOn(response)))
    }
    
    func onVideoTurnedOff(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        if let callId = response.subjectId, let container = callContainer(callId: callId) {
            container.handleVideoChange(on: false, response)
        }
        delegate?.chatEvent(event: .call(.turnVideoOff(response)))
    }
    
    func onCallEnded(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Int> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callEnded(response)))
        if let callId = asyncMessage.subjectId, let callContainer = callContainer(callId: callId) {
            callContainer.dispose()
            callContainers.removeAll(where: { $0.callId == callId })
        }
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
        if let startCall = response.result,
           let container = callContainers.first(where: {$0.callId == response.subjectId})
        {
            container.onCallStarted(startCall)
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

// MARK: Janus/Kurento events handlers.
extension CallManager {
    func subscribeToReceivingOffers(_ media: ReceivingMedia) {
        if let container = callContainer(callId: media.chatId) {
            container.subscribeToReceiveOffers(media)
        }        
    }
    
    func processSDPAnswer(_ res: RemoteSDPAnswerRes) {
        if let container = callContainer(callId: res.chatId) {
            container.processSDPAnswer(res)
        }
    }
   
    func processSDPOffer(_ res: RemoteSDPOfferRes) {
        if let container = callContainer(callId: res.chatId) {
            container.processSDPOffer(res)
        }
    }
    
    func onAddIceCandidate(_ res: AddIceCandidateRes, _ direction: RTCDirection) {
        if let container = callContainer(callId: res.chatId) {
            container.setPeerIceCandidate(res, direction)
        }
    }
    
    func processReceiveMetadata(_ metadata: ReceiveCallMetadata) {
        
    }
    
    func onSessionCreated(_ resp: CreateSessionResp) {
        /// Create sdp offer for local stream and send it.
        if let callId = resp.chatId, let container = callContainer(callId: callId) {
            container.createSDPOfferForLocal()
        }
    }
}

extension CallManager {
    func log(_ message: String) {
#if DEBUG
        chat.logger.log(title: "CHAT_CALL_MANAGER", message: message, persist: false, type: .internalLog)
#endif
    }
}

extension CallManager {
    
    /// Send a message directly to the Janus/Kurento Server.
    func send(_ asyncMessage: AsyncSnedable) {
        let config = chat.config
        guard let content = asyncMessage.content else { return }
        let asyncMessage = SendAsyncMessageVO(content: content,
                                              ttl: config.msgTTL,
                                              peerName: asyncMessage.peerName ?? config.asyncConfig.peerName,
                                              priority: config.msgPriority,
                                              uniqueId: (asyncMessage as? AsyncChatServerMessage)?.chatMessage.uniqueId)
        guard chat.state == .chatReady || chat.state == .asyncReady else { return }
        chat.logger.logJSON(title: "ChatCall", jsonString: asyncMessage.string ?? "", persist: false, type: .sent)
        let async = chat.asyncManager.asyncClient
        Task { @AsyncGlobalActor in
            await async?.send(message: asyncMessage)
        }
    }
}

extension CallManager {
    private func makeCallContainer(createCall: CreateCall, for state: CallState, typeCode: String?) -> CallContainer {
        return CallContainer(callId: createCall.callId,
                             state: state,
                             callType: createCall.type,
                             typeCode: typeCode,
                             isFrontCamera: isFrontCamera,
                             chat: chat)
    }
    
    private func callContainer(callId: Int) -> CallContainer? {
        callContainers.first(where: { $0.callId == callId })
    }
    
    func activeCallParticipants(callId: Int) -> [CallParticipantUserRTC]? {
        return callContainer(callId: callId)?.callParticipantsUserRTC
    }
}
