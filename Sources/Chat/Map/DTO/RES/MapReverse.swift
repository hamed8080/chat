//
// MapReverse.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class MapReverse: Codable {
    public var address: String?
    public var city: String?
    public var neighbourhood: String?
    public var inOddEvenZone: Bool?
    public var inTrafficZone: Bool?
    public var municipalityZone: String?
    public var state: String?

    private enum CodingKeys: String, CodingKey {
        case address
        case city
        case neighbourhood
        case inOddEvenZone = "in_odd_even_zone"
        case inTrafficZone = "in_traffic_zone"
        case municipalityZone = "municipality_zone"
        case state
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = (try? container.decodeIfPresent(String.self, forKey: .address)) ?? nil
        city = (try? container.decodeIfPresent(String.self, forKey: .city)) ?? nil
        neighbourhood = (try? container.decodeIfPresent(String.self, forKey: .neighbourhood)) ?? nil
        inOddEvenZone = (try? container.decodeIfPresent(Bool.self, forKey: .inOddEvenZone)) ?? nil
        inTrafficZone = (try? container.decodeIfPresent(Bool.self, forKey: .inTrafficZone)) ?? false
        municipalityZone = (try? container.decodeIfPresent(String.self, forKey: .municipalityZone)) ?? nil
        state = (try? container.decodeIfPresent(String.self, forKey: .state)) ?? nil
    }
}
