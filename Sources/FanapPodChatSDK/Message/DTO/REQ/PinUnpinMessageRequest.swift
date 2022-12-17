//
// PinUnpinMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

public class PinUnpinMessageRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let messageId: Int
    public let notifyAll: Bool
    var chatMessageType: ChatMessageVOTypes = .pinMessage
    var subjectId: Int { messageId }
    var content: String? { convertCodableToString() }

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
