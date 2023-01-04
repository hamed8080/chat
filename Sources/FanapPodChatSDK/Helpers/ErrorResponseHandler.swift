//
// ErrorResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Event
extension Chat {
    func onError(_ asyncMessage: AsyncMessage) {
        logger?.log(message: asyncMessage.string ?? "", level: LogLevel.error)
        let data = asyncMessage.chatMessage?.content?.data(using: .utf8) ?? Data()
        let chatError = try? JSONDecoder().decode(ChatError.self, from: data)
        delegate?.chatError(error: chatError ?? .init())
        if let chatMessage = asyncMessage.chatMessage, let callback: CompletionType<Voidcodable> = callbacksManager.getCallBack(chatMessage.uniqueId) {
            callback(.init(uniqueId: chatMessage.uniqueId, error: chatError))
            callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .error)
        }
    }
}
