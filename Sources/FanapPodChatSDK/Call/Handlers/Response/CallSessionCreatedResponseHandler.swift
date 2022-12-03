//
// CallSessionCreatedResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CallSessionCreatedResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .call(.callCreate(createCall)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: createCall))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callSessionCreated)

        chat.callState = .created
        startTimerTimeout(createCall)
    }

    /// end call if no one doesn't accept or available to answer call
    class func startTimerTimeout(_ createCall: CreateCall) {
        let chat = Chat.sharedInstance
        Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
            if chat.callState == .created {
                if chat.config?.isDebuggingLogEnabled == true {
                    Chat.sharedInstance.logger?.log(title: "cancel call after \(chat.config?.callTimeout ?? 0) second waiting to accept by user")
                }
                let call = Call(id: createCall.callId,
                                creatorId: 0,
                                type: createCall.type,
                                isGroup: false)
                let req = CancelCallRequest(call: call)
                chat.cancelCall(req) { _ in
                }
            }
            timer.invalidate()
        }
    }
}
