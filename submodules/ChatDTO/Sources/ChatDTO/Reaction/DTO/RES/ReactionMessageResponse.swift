//
// ReactionMessageResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ReactionMessageResponse: Decodable, Sendable {
    public var messageId: Int?
    public var reaction: Reaction?
    public var oldSticker: Sticker?

    public init(messageId: Int? = nil, reaction: Reaction? = nil, oldSticker: Sticker? = nil) {
        self.messageId = messageId
        self.reaction = reaction
        self.oldSticker = oldSticker
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case reactionVO
        case oldSticker
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        reaction = try container.decodeIfPresent(Reaction.self, forKey: .reactionVO)
        oldSticker = try container.decodeIfPresent(Sticker.self, forKey: .oldSticker)
    }
}
