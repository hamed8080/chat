//
// ForwardMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class ForwardMessageRequest: UniqueIdManagerRequest, Queueable, PlainTextSendable, SubjectProtocol {
    public let messageIds: [Int]
    public let threadId: Int
    public let uniqueIds: [String]
    var chatMessageType: ChatMessageVOTypes = .forwardMessage
    var subjectId: Int? { threadId }
    var content: String? { "\(messageIds)" }

    public init(threadId: Int,
                messageIds: [Int],
                uniqueId _: String? = nil)
    {
        self.threadId = threadId
        self.messageIds = messageIds
        var uniqueIds: [String] = []
        for _ in messageIds {
            uniqueIds.append(UUID().uuidString)
        }
        self.uniqueIds = uniqueIds
        super.init(uniqueId: "\(uniqueIds)")
    }
}
