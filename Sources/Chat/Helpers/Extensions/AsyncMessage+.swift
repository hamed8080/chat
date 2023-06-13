//
// AsyncMessage+.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

public extension AsyncMessage {
    var chatMessage: ChatMessage? {
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage = try? JSONDecoder.instance.decode(ChatMessage.self, from: chatMessageData) else { return nil }
        return chatMessage
    }

    internal func decodeContent<T: Decodable>() -> T? {
        guard let data = chatMessage?.content?.data(using: .utf8) else { return nil }
        return try? JSONDecoder.instance.decode(T.self, from: data)
    }

    var subjectId: Int? { chatMessage?.subjectId }

    func toChatResponse<T: Decodable>() -> ChatResponse<T> {
        ChatResponse(uniqueId: chatMessage?.uniqueId, result: decodeContent(), subjectId: chatMessage?.subjectId, time: chatMessage?.time)
    }

    func toChatResponse<T: Decodable>(asyncManager: AsyncManager) -> ChatResponse<T> {
        let chatMessage = chatMessage
        let pagination: (count: Int, offset: Int)? = asyncManager.pop(chatMessage?.uniqueId)
        let result: T? = decodeContent()
        let contentCount = chatMessage?.contentCount
        let receivedCount = (result as? any Collection)?.count ?? 0
        let hasNext = receivedCount >= pagination?.count ?? 0
        return ChatResponse(uniqueId: chatMessage?.uniqueId,
                            result: result,
                            contentCount: contentCount,
                            hasNext: hasNext,
                            subjectId: chatMessage?.subjectId,
                            time: chatMessage?.time)
    }

    /// There is two type  of decoding one with `Int` and another one with `MessageResponse.
    /// Caution: When receiving a new message and sending a new message `OnDeliver`, `OnSeen`, and `OnSent` have different behavior.
    func messageResponse(state: MessageResponseState) -> ChatResponse<MessageResponse>? {
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
            var response = messageResponse
            response.result?.messageState = state
            let chatRes: ChatResponse<MessageResponse> = ChatResponse(uniqueId: response.uniqueId,
                                                                      result: response.result,
                                                                      error: response.error,
                                                                      subjectId: response.subjectId,
                                                                      time: response.time)
            return chatRes
        } else {
            return nil
        }
    }

    var banError: BanError? {
        if chatMessage?.type == .error, let error: ChatError = toChatResponse().result, let ban = error.banError {
            return ban
        } else {
            return nil
        }
    }
}
