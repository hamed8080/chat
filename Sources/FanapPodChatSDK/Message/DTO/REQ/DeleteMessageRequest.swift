//
// DeleteMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class DeleteMessageRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let deleteForAll: Bool
    public let messageId: Int
    var subjectId: Int { messageId }
    var chatMessageType: ChatMessageVOTypes = .deleteMessage
    var content: String? { convertCodableToString() }

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
