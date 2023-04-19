//
// PinUnpinMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class PinUnpinMessageRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let messageId: Int
    public let notifyAll: Bool
    public var chatMessageType: ChatMessageVOTypes = .pinMessage
    public var subjectId: Int { messageId }
    public var content: String? { jsonString }

    public init(messageId: Int, notifyAll: Bool = false, uniqueId: String? = nil) {
        self.messageId = messageId
        self.notifyAll = notifyAll
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case notifyAll
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(notifyAll, forKey: .notifyAll)
    }
}
