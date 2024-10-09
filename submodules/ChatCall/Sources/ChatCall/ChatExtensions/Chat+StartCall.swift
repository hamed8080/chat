//
// Chat+StartCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore
import Async
import ChatModels

// Request
public extension ChatImplementation {
    /// Start request a call.
    /// - Parameters:
    ///   - request: The request to how to start the call as an example start call with a threadId.
    func requestCall(_ request: StartCallRequest) {
    ChatCall.instance?.callState = .requested
    prepareToSendAsync(req: request, type: .startCallRequest)
    startTimerTimeout()
}

    /// Start a group call with list of people or a threadId.
    /// - Parameters:
    ///   - request: A request that contains a list of people or a threadId.
    ///   - completion: A response that tell you if the call is created and contains a callId and more.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func requestGroupCall(_ request: StartCallRequest) {
    ChatCall.instance?.callState = .requested
    prepareToSendAsync(req: request, type: .groupCallRequest)
    startTimerTimeout()
}
}

// Internal
extension ChatImplementation {
    /// An internal method when a call has arrived.
    /// - Parameter request: A calId.
    internal func callReceived(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .deliveredCallRequest)
    }

    /// if newtork is unstable and async server cant respond with type CALL_SESSION_CREATED then we must end call  for starter to close UI
    func startTimerTimeout() {
        _ = ChatCall.instance?.callStartTimer?.scheduledTimer(interval: config.callConfig.callTimeout, repeats: false) { [weak self] timer in
            if ChatCall.instance?.callState == .requested {
                let message = "Call has been canceled by a timer timeout after waiting \(self?.config.callConfig.callTimeout ?? 0)"
                self?.logger.log(title: "ChatCall", message: message, persist: false, type: .internalLog)
                self?.delegate?.chatEvent(event: .call(.callEnded(nil)))
                ChatCall.instance?.callState = .ended
            }
            timer.invalidateTimer()
        }
    }
}

// Response
extension ChatImplementation {
    /// Only call on receivers side. The starter of call never get this event.
    func onStartCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callReceived(response)))
        ChatCall.instance?.callState = .requested
        startTimerTimeout(callId: response.result?.callId ?? 0)
        // SEND type 73 . This mean client receive call and showing ringing mode on call creator.
        callReceived(.init(subjectId: response.result?.callId ?? 0))
    }

    func onCallStarted(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<StartCall> = asyncMessage.toChatResponse()
        response.result?.callId = response.subjectId
        ChatCall.instance?.callState = .started
        if let callStarted = response.result {
            initWebRTC(callStarted)
        }
        delegate?.chatEvent(event: .call(.callStarted(response)))
    }

    // Only public for swiftui Preview
    public func initWebRTC(_ startCall: StartCall) {
        /// simulator File name
        let smFileName = TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil
        let config = WebRTCConfig(callConfig: config.callConfig, startCall: startCall, isSendVideoEnabled: startCall.clientDTO.video, fileName: smFileName)
        ChatCall.instance?.webrtc = WebRTCClient(chat: self, config: config, delegate: callDelegate)
        let me = CallParticipant(sendTopic: config.topicSend ?? "", userId: userInfo?.id, mute: startCall.clientDTO.mute, video: startCall.clientDTO.video, participant: .init(name: "ME"))
        var users = [me]
        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userInfo?.id }.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend, userId: clientDTO.userId, mute: clientDTO.mute, video: clientDTO.video)
        }
        users.append(contentsOf: otherUsers ?? [])
        ChatCall.instance?.webrtc?.addCallParticipants(users)
        ChatCall.instance?.webrtc?.createSession()
    }

    func onDeliverCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callDelivered(response)))
    }

    /// maybe starter of call after start call request disconnected we need to close ui on the receiver side
    func startTimerTimeout(callId: Int) {
        _ = ChatCall.instance?.callStartTimer?.scheduledTimer(interval: config.callConfig.callTimeout, repeats: false) { [weak self] timer in
            // If the user clicks on reject button the chat.callStatus = .cacnceled and bottom code will not be executed.
            if ChatCall.instance?.callState == .requested {
                let message = "Call has been canceled by a timer timeout after waiting \(self?.config.callConfig.callTimeout ?? 0)"
                self?.logger.log(title: "ChatCall", message: message, persist: false, type: .internalLog)
                self?.delegate?.chatEvent(event: .call(.callEnded(.init(result: callId))))
                ChatCall.instance?.callState = .ended
            }
            timer.invalidateTimer()
        }
    }

    func onCallSessionCreated(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callCreate(response)))
        ChatCall.instance?.callState = .created
        if let createCall = response.result {
            startTimerTimeout(createCall)
        }
    }

    /// end call if no one doesn't accept or available to answer call
    func startTimerTimeout(_ createCall: CreateCall) {
        _ = ChatCall.instance?.callStartTimer?.scheduledTimer(interval: config.callConfig.callTimeout, repeats: false) { [weak self] timer in
            if ChatCall.instance?.callState == .created {
                let message = "Call has been canceled by a timer timeout after waiting \(self?.config.callConfig.callTimeout ?? 0)"
                self?.logger.log(title: "ChatCall", message: message, persist: false, type: .internalLog)
                let call = Call(id: createCall.callId,
                                creatorId: 0,
                                type: createCall.type,
                                isGroup: false)
                let req = CancelCallRequest(call: call)
                self?.cancelCall(req)
            }
            timer.invalidateTimer()
        }
    }

    func onCallParticipantLeft(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantLeft(response)))
        response.result?.forEach { callParticipant in
            ChatCall.instance?.webrtc?.removeCallParticipant(callParticipant)
            if callParticipant.userId == userInfo?.id {
                ChatCall.instance?.webrtc?.clearResourceAndCloseConnection()
            }
        }
    }

    func onRejectCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callRejected(response)))
    }
}
