//
// ErrorResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

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
        let data = asyncMessage.chatMessage?.content?.data(using: .utf8) ?? Data()
        let chatError = try? JSONDecoder().decode(ChatError.self, from: data)
        delegate?.chatError(error: chatError ?? .init())
        if let chatMessage = asyncMessage.chatMessage, let callback: CompletionType<Voidcodable> = callbacksManager.getCallBack(chatMessage.uniqueId) {
            callback(.init(uniqueId: chatMessage.uniqueId, error: chatError))
            callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .error)
        }
    }
}
