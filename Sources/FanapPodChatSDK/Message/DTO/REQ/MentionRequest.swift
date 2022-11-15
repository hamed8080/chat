//
// MentionRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class MentionRequest: BaseRequest, ChatSnedable, SubjectProtocol {
    public var count: Int = 50
    public var offset: Int = 0
    public let threadId: Int
    public let onlyUnreadMention: Bool
    var content: String? { convertCodableToString() }
    var subjectId: Int? { threadId }
    var chatMessageType: ChatMessageVOTypes = .getHistory

    public init(threadId: Int,
                onlyUnreadMention: Bool,
                count: Int = 50,
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
