
// ReactionList.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ReactionList: Decodable, Hashable, Identifiable {
    public var id: Int? { messageId }
    public var messageId: Int?
    public var reactions: [Reaction]?

    public init(from decoder: Decoder) throws {
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
