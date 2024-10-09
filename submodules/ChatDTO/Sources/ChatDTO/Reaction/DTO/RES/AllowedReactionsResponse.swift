//
// AllowedReactionsResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AllowedReactionsResponse: Decodable {
    public var conversationId: Int?
    public var allowedReactions: [Sticker]?

    public init(conversationId: Int? = nil, allowedReactions: [Sticker]? = nil) {
        self.conversationId = conversationId
        self.allowedReactions = allowedReactions
    }

    private enum CodingKeys: String, CodingKey {
        case threadId
        case stickerList
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conversationId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        allowedReactions = try container.decodeIfPresent([Sticker].self, forKey: .stickerList)
    }
}
