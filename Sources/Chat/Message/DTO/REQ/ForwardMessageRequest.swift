//
// ForwardMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
public final class ForwardMessageRequest: UniqueIdManagerRequest, Queueable, PlainTextSendable, SubjectProtocol {
    public var queueTime: Date = .init()
    public let messageIds: [Int]
    public let fromThreadId: Int
    public let threadId: Int
    public var uniqueIds: [String]
    var chatMessageType: ChatMessageVOTypes = .forwardMessage
    var subjectId: Int { threadId }
    var content: String? { "\(messageIds)" }
    internal var typeCode: String?

    public init(fromThreadId: Int,
                threadId: Int,
                messageIds: [Int],
                uniqueIds: [String] = [])
    {
        self.fromThreadId = fromThreadId
        self.threadId = threadId
        self.messageIds = messageIds
        self.uniqueIds = uniqueIds
        if self.uniqueIds.count == 0 {
            var uniqueIds: [String] = []
            for _ in messageIds {
                uniqueIds.append(UUID().uuidString)
            }
            self.uniqueIds = uniqueIds
        }
        super.init(uniqueId: "\(self.uniqueIds)")
    }
}
