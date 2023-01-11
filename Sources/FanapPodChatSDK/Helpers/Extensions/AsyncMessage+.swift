//
// AsyncMessage+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import FanapPodAsyncSDK
import Foundation

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

public extension AsyncMessage {
    internal var chatMessage: ChatMessage? {
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: chatMessageData) else { return nil }
        return chatMessage
    }

    internal func decodeContent<T: Decodable>() -> T? {
        guard let data = chatMessage?.content?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    var subjectId: Int? { chatMessage?.subjectId }

    func toChatResponse<T: Decodable>() -> ChatResponse<T> {
        ChatResponse(uniqueId: chatMessage?.uniqueId, result: decodeContent(), subjectId: chatMessage?.subjectId, time: chatMessage?.time)
    }

    func messageResponse(state _: MessageResposneState) -> ChatResponse<MessageResponse> {
        let response: ChatResponse<Int> = toChatResponse()
        let messageSent = MessageResponse(messageState: .sent,
                                          threadId: response.subjectId,
                                          participantId: nil,
                                          messageId: response.result,
                                          messageTime: UInt(response.time ?? 0))
        let chatRes: ChatResponse<MessageResponse> = ChatResponse(uniqueId: response.uniqueId,
                                                                  result: messageSent,
                                                                  error: response.error,
                                                                  subjectId: response.subjectId,
                                                                  time: response.time)
        return chatRes
    }
}
