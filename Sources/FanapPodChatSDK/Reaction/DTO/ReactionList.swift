
// ReactionList.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

open class ReactionList: Decodable, Hashable, Identifiable {
    public static func == (lhs: ReactionList, rhs: ReactionList) -> Bool {
        lhs.messageId == rhs.messageId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }

    public var messageId: Int?
    public var reactions: [Reaction]?

    public required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        reactions = try container.decodeIfPresent([Reaction].self, forKey: .reactionVOList)
    }

    public init(messageId: Int? = nil, reactions: [Reaction]? = nil) {
        self.messageId = messageId
        self.reactions = reactions
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case reactionVOList
    }
}
