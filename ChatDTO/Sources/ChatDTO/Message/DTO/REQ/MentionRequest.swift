//
// MentionRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class MentionRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var count: Int = 25
    public var offset: Int = 0
    public let threadId: Int
    public let onlyUnreadMention: Bool
    public var content: String? { jsonString }
    public var subjectId: Int { threadId }
    public var chatMessageType: ChatMessageVOTypes = .getHistory

    public init(threadId: Int,
                onlyUnreadMention: Bool,
                count: Int = 25,
                offset: Int = 0,
                uniqueId: String? = nil)
    {
        self.count = count
        self.offset = offset
        self.threadId = threadId
        self.onlyUnreadMention = onlyUnreadMention
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case unreadMentioned
        case allMentioned
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(offset, forKey: .offset)
        if onlyUnreadMention {
            try container.encode(true, forKey: .unreadMentioned)
        } else {
            try container.encode(true, forKey: .allMentioned)
        }
    }
}
