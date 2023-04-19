//
// DeleteMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class DeleteMessageRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let deleteForAll: Bool
    public let messageId: Int
    public var subjectId: Int { messageId }
    public var chatMessageType: ChatMessageVOTypes = .deleteMessage
    public var content: String? { jsonString }

    public init(deleteForAll: Bool? = false,
                messageId: Int,
                uniqueId: String? = nil)
    {
        self.deleteForAll = deleteForAll ?? false
        self.messageId = messageId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case deleteForAll
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deleteForAll, forKey: .deleteForAll)
    }
}
