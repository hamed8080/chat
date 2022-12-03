//
// StartCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class StartCallRequestHandler {
    class func handle(_ req: StartCallRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<CreateCall>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.callState = .requested
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? CreateCall, response.uniqueId, response.error)
        }
        startTimerTimeout()
    }

    /// if newtork is unstable and async server cant respond with type CALL_SESSION_CREATED then we must end call  for starter to close UI
    class func startTimerTimeout() {
        let chat = Chat.sharedInstance
        Timer.scheduledTimer(withTimeInterval: chat.config?.callTimeout ?? 0, repeats: false) { timer in
            if chat.callState == .requested {
                if chat.config?.isDebuggingLogEnabled == true {
                    Chat.sharedInstance.logger?.log(title: "cancel call after \(chat.config?.callTimeout ?? 0) second no response back from server with type CALL_SESSION_CREATED")
                }
                chat.delegate?.chatEvent(event: .call(.callEnded(nil)))
                chat.callState = .ended
            }
            timer.invalidate()
        }
    }
}
