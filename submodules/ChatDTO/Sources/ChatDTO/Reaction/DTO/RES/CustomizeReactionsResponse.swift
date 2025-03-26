//
// CustomizeReactionsResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct CustomizeReactionsResponse: Decodable, Sendable {
    public var reactionStatus: ReactionStatus?
    public var allowedReactions: [Sticker]?

    public init(reactionStatus: ReactionStatus? = nil, allowedReactions: [Sticker]? = nil) {
        self.reactionStatus = reactionStatus
        self.allowedReactions = allowedReactions
    }

    private enum CodingKeys: String, CodingKey {
        case reactionStatus
        case allowedReactions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reactionStatus = try container.decodeIfPresent(ReactionStatus.self, forKey: .reactionStatus)
        allowedReactions = try container.decodeIfPresent([Sticker].self, forKey: .allowedReactions)
    }
}
