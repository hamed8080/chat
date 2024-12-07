
// Reaction.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Reaction: Codable, Hashable, Identifiable, Sendable {
    public var id: Int?
    public var time: UInt?
    public var reaction: Sticker?
    public var participant: Participant?

    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        reaction = try container.decodeIfPresent(Sticker.self, forKey: .reaction)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participantVO)
        time = try container.decodeIfPresent(UInt.self, forKey: .time)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
    }

    public init(id: Int? = nil, reaction: Sticker? = nil, participant: Participant? = nil, time: UInt? = nil) {
        self.id = id
        self.time = time
        self.reaction = reaction
        self.participant = participant
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case time
        case reaction
        case participantVO
    }

    public func encode(to encoder: Encoder) throws {}
}
