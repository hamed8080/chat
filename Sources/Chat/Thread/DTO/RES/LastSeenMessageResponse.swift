//
// LastSeenMessageResponse.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

struct LastSeenMessageResponse: Decodable {
    let id: Int?
    var uniqueId: String?
    let unreadCount: Int?

    enum CodingKeys: CodingKey {
        case id
        case unreadCount
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try container?.decodeIfPresent(Int.self, forKey: .id)
        unreadCount = try container?.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
    }
}
