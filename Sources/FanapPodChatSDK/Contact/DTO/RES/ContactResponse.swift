//
// ContactResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public class ContactResponse: Decodable {
    public var contentCount: Int = 0
    public var contacts: [Contact] = []

    private enum CodingKeys: String, CodingKey {
        case contacts = "result"
        case contentCount = "count"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let contacts = try? container.decodeIfPresent([Contact].self, forKey: .contacts) {
            self.contacts = contacts ?? []
        }
        contentCount = try container.decodeIfPresent(Int.self, forKey: .contentCount) ?? 0
    }
}
