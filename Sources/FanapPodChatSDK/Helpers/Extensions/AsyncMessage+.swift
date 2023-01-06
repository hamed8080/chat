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

extension AsyncMessage {
    var chatMessage: ChatMessage? {
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: chatMessageData) else { return nil }
        return chatMessage
    }

    func decodeContent<T: Decodable>(context: NSManagedObjectContext) -> T? {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context] = context
        guard let data = chatMessage?.content?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    public var subjectId: Int? { chatMessage?.subjectId }

    public func toChatResponse<T: Decodable>(context: NSManagedObjectContext) -> ChatResponse<T> {
        ChatResponse(uniqueId: chatMessage?.uniqueId, result: decodeContent(context: context), subjectId: chatMessage?.subjectId, time: chatMessage?.time)
    }
}
