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

    /// There is two type  of decoding one with `Int` and another one with `MessageResponse.
    /// Caution: When receiving a new message and sending a new message `OnDeliver`, `OnSeen`, and `OnSent` have different behavior.
    func messageResponse(state: MessageResposneState) -> ChatResponse<MessageResponse>? {
        let idResponse: ChatResponse<Int> = toChatResponse()
        let messageResponse: ChatResponse<MessageResponse> = toChatResponse()
        if idResponse.result != nil {
            let messageSent = MessageResponse(messageState: state,
                                              threadId: idResponse.subjectId,
                                              participantId: nil,
                                              messageId: idResponse.result,
                                              messageTime: UInt(idResponse.time ?? 0))
            let chatRes: ChatResponse<MessageResponse> = ChatResponse(uniqueId: idResponse.uniqueId,
                                                                      result: messageSent,
                                                                      error: idResponse.error,
                                                                      subjectId: idResponse.subjectId,
                                                                      time: idResponse.time)
            return chatRes
        } else if messageResponse.result != nil {
            messageResponse.result?.messageState = state
            let chatRes: ChatResponse<MessageResponse> = ChatResponse(uniqueId: messageResponse.uniqueId,
                                                                      result: messageResponse.result,
                                                                      error: messageResponse.error,
                                                                      subjectId: messageResponse.subjectId,
                                                                      time: messageResponse.time)
            return chatRes
        } else {
            return nil
        }
    }
}