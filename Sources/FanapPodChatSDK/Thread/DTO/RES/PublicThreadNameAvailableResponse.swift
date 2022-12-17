//
// PublicThreadNameAvailableResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public struct PublicThreadNameAvailableResponse: Decodable {
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
}
