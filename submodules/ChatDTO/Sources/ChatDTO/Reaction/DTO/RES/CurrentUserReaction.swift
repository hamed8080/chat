//
// CurrentUserReaction.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct CurrentUserReaction: Decodable {
    public var messageId: Int?
    public var reaction: Reaction?

    public init(messageId: Int? = nil, reaction: Reaction? = nil) {
        self.messageId = messageId
        self.reaction = reaction
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case reactionVO
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        reaction = try container.decodeIfPresent(Reaction.self, forKey: .reactionVO)
    }
}
