//
// PublicThreadNameAvailableResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct PublicThreadNameAvailableResponse: Decodable, Sendable {
    private let uniqueName: String?
    public var name: String?

    private enum CodingKeys: String, CodingKey {
        case uniqueName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uniqueName = try container.decodeIfPresent(String.self, forKey: .uniqueName)
        if let data = uniqueName?.data(using: .utf8),
           let dictionary = try? JSONDecoder().decode([String: String].self, from: data)
        {
            name = dictionary["name"]
        }
    }

    public init(uniqueName: String? = nil, name: String? = nil) {
        self.uniqueName = uniqueName
        self.name = name
    }
}
