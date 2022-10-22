//
// ForwardInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

open class ForwardInfo: Codable {
    public var conversation: Conversation?
    public var participant: Participant?

    private enum CodingKeys: String, CodingKey {
        case conversation
        case participant
    }

    public init(conversation: Conversation?, participant: Participant?) {
        self.conversation = conversation
        self.participant = participant
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conversation = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
    }
}
