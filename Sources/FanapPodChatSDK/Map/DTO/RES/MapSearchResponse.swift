//
// MapSearchResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

open class MapSearchResponse: Decodable {
    public var count: Int
    public var items: [MapItem]?

    private enum CodingKeys: String, CodingKey {
        case count
        case items
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = (try container.decodeIfPresent(Int.self, forKey: .count)) ?? 0
        items = (try container.decodeIfPresent([MapItem].self, forKey: .items)) ?? nil
    }
}

open class MapItem: Codable {
    public let address: String?
    public let category: String?
    public let region: String?
    public let type: String?
    public let title: String?
    public var location: Location?
    public var neighbourhood: String?
}

open class Location: Codable {
    public let x: Double
    public let y: Double
}
