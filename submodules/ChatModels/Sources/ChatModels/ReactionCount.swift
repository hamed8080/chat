
// ReactionCountList.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ReactionCount: Codable, Hashable, Identifiable {
    public var sticker: Sticker?
    public var count: Int?
    public var id: Int { hashValue }

    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        sticker = try container.decodeIfPresent(Sticker.self, forKey: .sticker)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
    }

    public init(sticker: Sticker? = nil, count: Int? = nil) {
        self.sticker = sticker
        self.count = count
    }

    private enum CodingKeys: String, CodingKey {
        case sticker
        case count
    }
}
