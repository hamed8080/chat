//
// PinUnpinMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

open class PinUnpinMessage: Codable {
    public let messageId: Int
    public let notifyAll: Bool
    public let text: String?
    public let sender: Participant?
    public let time: Int?

    public init(messageId: Int,
                notifyAll: Bool,
                text: String?,
                sender: Participant?,
                time: Int?)
    {
        self.messageId = messageId
        self.notifyAll = notifyAll
        self.text = text
        self.sender = sender
        self.time = time
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case notifyAll
        case text
        case sender
        case time
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decode(Int.self, forKey: .messageId)
        notifyAll = try container.decodeIfPresent(Bool.self, forKey: .notifyAll) ?? false
        text = try container.decodeIfPresent(String.self, forKey: .text)
        sender = try container.decodeIfPresent(Participant.self, forKey: .sender)
        time = try container.decodeIfPresent(Int.self, forKey: .time)
    }
}
