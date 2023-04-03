//
// SendSignalMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class SendSignalMessageRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let signalType: SignalMessageType
    public let threadId: Int
    var subjectId: Int { threadId }
    var chatMessageType: ChatMessageVOTypes = .systemMessage
    var content: String? { jsonString }

    public init(signalType: SignalMessageType, threadId: Int, uniqueId: String? = nil) {
        self.signalType = signalType
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(signalType.rawValue)", forKey: .type)
    }
}
