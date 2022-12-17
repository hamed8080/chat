//
// AsyncMessage+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import FanapPodAsyncSDK
import Foundation
extension AsyncMessage {
    var chatMessage: ChatMessage? {
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: chatMessageData) else { return nil }
        return chatMessage
    }

    func decodeContent<T: Decodable>() -> T? {
        guard let data = chatMessage?.content?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    public var subjectId: Int? { chatMessage?.subjectId }

    public func toChatResponse<T: Decodable>() -> ChatResponse<T> {
        ChatResponse(uniqueId: chatMessage?.uniqueId, result: decodeContent(), subjectId: chatMessage?.subjectId, time: chatMessage?.time)
    }
}
