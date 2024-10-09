//
// ContactResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ContactResponse: Decodable {
    public var contentCount: Int = 0
    public var contacts: [Contact] = []

    private enum CodingKeys: String, CodingKey {
        case contacts = "result"
        case contentCount = "count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let contacts = try? container.decodeIfPresent([Contact].self, forKey: .contacts) ?? [] {
            self.contacts = contacts
        }
        contentCount = try container.decodeIfPresent(Int.self, forKey: .contentCount) ?? 0
    }

    public init(contentCount: Int = 0, contacts: [Contact] = []) {
        self.contentCount = contentCount
        self.contacts = contacts
    }
}
