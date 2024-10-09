//
// MapSearchResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapSearchResponse: Decodable {
    public var count: Int
    public var items: [MapItem]?

    private enum CodingKeys: String, CodingKey {
        case count
        case items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = (try container.decodeIfPresent(Int.self, forKey: .count)) ?? 0
        items = (try container.decodeIfPresent([MapItem].self, forKey: .items)) ?? nil
    }

    public init(count: Int, items: [MapItem]? = nil) {
        self.count = count
        self.items = items
    }
}

public struct MapItem: Codable {
    public let address: String?
    public let category: String?
    public let region: String?
    public let type: String?
    public let title: String?
    public var location: Location?
    public var neighbourhood: String?

    private enum CodingKeys: CodingKey {
        case address
        case category
        case region
        case type
        case title
        case location
        case neighbourhood
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        self.neighbourhood = try container.decodeIfPresent(String.self, forKey: .neighbourhood)
    }

    public init(address: String? = nil, category: String? = nil, region: String? = nil, type: String? = nil, title: String? = nil, location: Location? = nil, neighbourhood: String? = nil) {
        self.address = address
        self.category = category
        self.region = region
        self.type = type
        self.title = title
        self.location = location
        self.neighbourhood = neighbourhood
    }
}

public struct Location: Codable {
    public let x: Double
    public let y: Double

    private enum CodingKeys: CodingKey {
        case x
        case y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try container.decode(Double.self, forKey: .x)
        self.y = try container.decode(Double.self, forKey: .y)
    }

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
