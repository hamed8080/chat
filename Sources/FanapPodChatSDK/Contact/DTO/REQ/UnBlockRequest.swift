//
// UnBlockRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class UnBlockRequest: UniqueIdManagerRequest, ChatSnedable {
    public let contactId: Int?
    public let threadId: Int?
    public let userId: Int?
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .unblock

    public init(contactId: Int? = nil,
                threadId: Int? = nil,
                userId: Int? = nil,
                uniqueId: String? = nil)
    {
        self.contactId = contactId
        self.threadId = threadId
        self.userId = userId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case contactId
        case threadId
        case userId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(contactId, forKey: .contactId)
        try? container.encodeIfPresent(threadId, forKey: .threadId)
        try? container.encodeIfPresent(userId, forKey: .userId)
    }
}
