//
// Chat+Error.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Async
import Foundation

// Event
extension Chat {
    func onError(_ asyncMessage: AsyncMessage) {
        logger.logJSON(title: "onError:", jsonString: asyncMessage.string, persist: true, type: .received, userInfo: loggerUserInfo)
        let data = asyncMessage.chatMessage?.content?.data(using: .utf8) ?? Data()
        let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data)
        delegate?.chatError(error: chatError ?? .init())
        if let chatMessage = asyncMessage.chatMessage, let callback: CompletionType<Voidcodable> = callbacksManager.getCallBack(chatMessage.uniqueId) {
            callback(.init(uniqueId: chatMessage.uniqueId, error: chatError))
            callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .error)
        }
    }
}
