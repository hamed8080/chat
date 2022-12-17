//
// LeaveThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class LeaveThreadRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let threadId: Int
    public let clearHistory: Bool?
    var subjectId: Int { threadId }
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .leaveThread

    public init(threadId: Int, clearHistory: Bool? = false, uniqueId: String? = nil) {
        self.clearHistory = clearHistory
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case clearHistory
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(clearHistory, forKey: .clearHistory)
    }
}
