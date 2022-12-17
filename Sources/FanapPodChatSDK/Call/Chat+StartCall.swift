//
// Chat+StartCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    /// Start request a call.
    /// - Parameters:
    ///   - request: The request to how to start the call as an example start call with a threadId.
    ///   - completion: A response that tell you if the call is created and contains a callId and more.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func requestCall(_ request: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        callState = .requested
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        startTimerTimeout()
    }

    /// Start a group call with list of people or a threadId.
    /// - Parameters:
    ///   - request: A request that contains a list of people or a threadId.
    ///   - completion: A response that tell you if the call is created and contains a callId and more.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func requestGroupCall(_ request: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        callState = .requested
        request.chatMessageType = .groupCallRequest
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        startTimerTimeout()
    }

    /// An internal method when a call has arrived.
    /// - Parameter request: A calId.
    internal func callReceived(_ request: GeneralSubjectIdRequest) {
        request.chatMessageType = .deliveredCallRequest
        prepareToSendAsync(req: request)
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
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callReceived(response)))
        callState = .requested
        startTimerTimeout(callId: response.result?.callId ?? 0)
        // SEND type 73 . This mean client receive call and showing ringing mode on call creator.
        callReceived(.init(subjectId: response.result?.callId ?? 0))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    func onCallStarted(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<StartCall> = asyncMessage.toChatResponse()
        response.result?.callId = response.subjectId
        callState = .started
        if let callStarted = response.result {
            initWebRTC(callStarted)
        }
        delegate?.chatEvent(event: .call(.callStarted(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
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
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callDelivered(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    /// maybe starter of call after start call request disconnected we need to close ui on the receiver side
    func startTimerTimeout(callId: Int) {
        _ = callStartTimer?.scheduledTimer(withTimeInterval: config.callTimeout, repeats: false) { [weak self] timer in
            // If the user clicks on reject button the chat.callStatus = .cacnceled and bottom code will not be executed.
            if self?.callState == .requested {
                if self?.config.isDebuggingLogEnabled == true {
                    self?.logger?.log(title: "cancel call after \(self?.config.callTimeout ?? 0) second")
                }
                self?.delegate?.chatEvent(event: .call(.callEnded(.init(result: callId))))
                self?.callState = .ended
            }
            timer.invalidate()
        }
    }

    func onCallSessionCreated(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callCreate(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
        callState = .created
        if let createCall = response.result {
            startTimerTimeout(createCall)
        }
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
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callParticipantLeft(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    func onRejectCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callRejected(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
