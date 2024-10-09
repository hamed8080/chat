//
// MapReverse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapReverse: Codable {
    public var address: String?
    public var city: String?
    public var neighbourhood: String?
    public var inOddEvenZone: Bool?
    public var inTrafficZone: Bool?
    public var municipalityZone: String?
    public var state: String?
    public var formattedAddress: String?

    private enum CodingKeys: String, CodingKey {
        case address
        case city
        case neighbourhood
        case inOddEvenZone = "in_odd_even_zone"
        case inTrafficZone = "in_traffic_zone"
        case municipalityZone = "municipality_zone"
        case state
        case formattedAddress = "formatted_address"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = (try? container.decodeIfPresent(String.self, forKey: .address)) ?? nil
        city = (try? container.decodeIfPresent(String.self, forKey: .city)) ?? nil
        neighbourhood = (try? container.decodeIfPresent(String.self, forKey: .neighbourhood)) ?? nil
        inOddEvenZone = (try? container.decodeIfPresent(Bool.self, forKey: .inOddEvenZone)) ?? nil
        inTrafficZone = (try? container.decodeIfPresent(Bool.self, forKey: .inTrafficZone)) ?? false
        municipalityZone = (try? container.decodeIfPresent(String.self, forKey: .municipalityZone)) ?? nil
        state = (try? container.decodeIfPresent(String.self, forKey: .state)) ?? nil
        formattedAddress = (try? container.decodeIfPresent(String.self, forKey: .formattedAddress)) ?? nil
    }

    public init(address: String? = nil, city: String? = nil, neighbourhood: String? = nil, inOddEvenZone: Bool? = nil, inTrafficZone: Bool? = nil, municipalityZone: String? = nil, state: String? = nil, formattedAddress: String? = nil) {
        self.address = address
        self.city = city
        self.neighbourhood = neighbourhood
        self.inOddEvenZone = inOddEvenZone
        self.inTrafficZone = inTrafficZone
        self.municipalityZone = municipalityZone
        self.state = state
        self.formattedAddress = formattedAddress
    }
}
