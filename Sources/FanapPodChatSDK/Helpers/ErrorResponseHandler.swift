//
// ErrorResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
import Sentry

// Event
extension Chat {
    func onError(_ asyncMessage: AsyncMessage) {
        logger?.log(title: "Message of type 'ERROR' recieved", jsonString: asyncMessage.string)
        // send log to Sentry 4.3.1
        if config.captureLogsOnSentry {
            let event = Event(level: SentrySeverity.error)
            event.message = "Message of type 'ERROR' recieved: \n \(asyncMessage.convertCodableToString() ?? "")"
            Client.shared?.send(event: event, completion: { _ in })
        }

        if let chatMessage = asyncMessage.chatMessage, let callback: CompletionType<Voidcodable> = callbacksManager.getCallBack(chatMessage.uniqueId) {
            let code: Int
            let message: String
            let content: String

            if let data = chatMessage.content?.data(using: .utf8), let chatError = try? JSONDecoder().decode(ChatError.self, from: data) {
                code = chatError.errorCode ?? 0
                message = chatError.message ?? ""
                content = chatError.content ?? ""
            } else {
                code = chatMessage.code ?? 0
                content = asyncMessage.convertCodableToString() ?? ""
                message = chatMessage.message ?? ""
            }

            callback(.init(uniqueId: chatMessage.uniqueId, error: .init(message: message, errorCode: code, hasError: true, content: content)))
            delegate?.chatError(error: .init(errorCode: code, message: message, content: content))
            callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .error)
        }
    }
}
