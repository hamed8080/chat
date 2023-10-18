//
// RactionCountRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class RactionCountRequest: UniqueIdManagerRequest, Encodable, ChatSendable, SubjectProtocol {
    public var messageIds: [Int]
    public let conversationId: Int
    var chatMessageType: ChatMessageVOTypes = .reactionCount
    var content: String? { "\(messageIds)" }
    var subjectId: Int { conversationId }

    public init(messageIds: [Int], conversationId: Int, uniqueId: String? = nil) {
        self.messageIds = messageIds
        self.conversationId = conversationId
        super.init(uniqueId: uniqueId)
    }
}
