//
// Chat+StartCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestStartCall(_ req: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        callState = .requested
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        startTimerTimeout()
    }

    func requestStartGroupCall(_ req: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        callState = .requested
        req.chatMessageType = .groupCallRequest
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        startTimerTimeout()
    }

    func requestReceivedCall(_ req: GeneralSubjectIdRequest) {
        req.chatMessageType = .deliveredCallRequest
        prepareToSendAsync(req: req)
    }

    /// if newtork is unstable and async server cant respond with type CALL_SESSION_CREATED then we must end call  for starter to close UI
    func startTimerTimeout() {
        _ = callStartTimer?.scheduledTimer(withTimeInterval: config.callTimeout, repeats: false) { [weak self] timer in
            if self?.callState == .requested {
                if self?.config.isDebuggingLogEnabled == true {
                    self?.logger?.log(title: "cancel call after \(self?.config.callTimeout ?? 0) second no response back from server with type CALL_SESSION_CREATED")
                }
                self?.delegate?.chatEvent(event: .call(.callEnded(nil)))
                self?.callState = .ended
            }
            timer.invalidate()
        }
    }
}

// Response
extension Chat {
    /// Only call on receivers side. The starter of call never get this event.
    func onStartCall(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callReceived(createCall)))
        callState = .requested
        startTimerTimeout(callId: createCall.callId)
        // SEND type 73 . This mean client receive call and showing ringing mode on call creator.
        callReceived(.init(subjectId: createCall.callId))
        guard let callback: CompletionType<CreateCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: createCall))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .startCallRequest)
    }

    func onCallStarted(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard var callStarted = try? JSONDecoder().decode(StartCall.self, from: data) else { return }
        callStarted.callId = chatMessage.subjectId
        callState = .started
        initWebRTC(callStarted)
        delegate?.chatEvent(event: .call(.callStarted(callStarted)))
        guard let callback: CompletionType<StartCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callStarted))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .startCallRequest)
    }

    // Only public for swiftui Preview
    public func initWebRTC(_ startCall: StartCall) {
        /// simulator File name
        let smFileName = TARGET_OS_SIMULATOR != 0 ? "webrtc_user_a.mp4" : nil
        let config = WebRTCConfig(startCall: startCall, isSendVideoEnabled: startCall.clientDTO.video, fileName: smFileName)
        webrtc = WebRTCClient(chat: self, config: config, delegate: callDelegate)
        let me = CallParticipant(sendTopic: config.topicSend ?? "", userId: userInfo?.id, mute: startCall.clientDTO.mute, video: startCall.clientDTO.video, participant: .init(name: "ME"))
        var users = [me]
        let otherUsers = startCall.otherClientDtoList?.filter { $0.userId != userInfo?.id }.compactMap { clientDTO in
            CallParticipant(sendTopic: clientDTO.topicSend, userId: clientDTO.userId, mute: clientDTO.mute, video: clientDTO.video)
        }
        users.append(contentsOf: otherUsers ?? [])
        webrtc?.addCallParticipants(users)
        webrtc?.createSession()
    }

    func onDeliverCall(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callDelivered(call)))
        guard let callback: CompletionType<Call> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: call))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deliveredCallRequest)
    }

    /// maybe starter of call after start call request disconnected we need to close ui on the receiver side
    func startTimerTimeout(callId: Int) {
        _ = callStartTimer?.scheduledTimer(withTimeInterval: config.callTimeout, repeats: false) { [weak self] timer in
            // If the user clicks on reject button the chat.callStatus = .cacnceled and bottom code will not be executed.
            if self?.callState == .requested {
                if self?.config.isDebuggingLogEnabled == true {
                    self?.logger?.log(title: "cancel call after \(self?.config.callTimeout ?? 0) second")
                }
                self?.delegate?.chatEvent(event: .call(.callEnded(callId)))
                self?.callState = .ended
            }
            timer.invalidate()
        }
    }

    func onCallSessionCreated(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callCreate(createCall)))
        guard let callback: CompletionType<CreateCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: createCall))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callSessionCreated)
        callState = .created
        startTimerTimeout(createCall)
    }

    /// end call if no one doesn't accept or available to answer call
    func startTimerTimeout(_ createCall: CreateCall) {
        _ = callStartTimer?.scheduledTimer(withTimeInterval: config.callTimeout, repeats: false) { [weak self] timer in
            if self?.callState == .created {
                if self?.config.isDebuggingLogEnabled == true {
                    self?.logger?.log(title: "cancel call after \(self?.config.callTimeout ?? 0) second waiting to accept by user")
                }
                let call = Call(id: createCall.callId,
                                creatorId: 0,
                                type: createCall.type,
                                isGroup: false)
                let req = CancelCallRequest(call: call)
                self?.cancelCall(req) { _ in
                }
            }
            timer.invalidate()
        }
    }

    func onCallParticipantLeft(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callParticipantLeft(callParticipants)))
        guard let callback: CompletionType<[CallParticipant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callParticipants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .leaveCall)
    }

    func onRejectCall(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callRejected(createCall)))
        guard let callback: CompletionType<CreateCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: createCall))
    }
}
