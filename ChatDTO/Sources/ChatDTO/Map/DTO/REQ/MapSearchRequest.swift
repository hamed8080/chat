//
// MapSearchRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore

public final class MapSearchRequest: UniqueIdManagerRequest, Encodable {
    public let lat: Double
    public let lng: Double
    public let term: String

    public init(lat: Double,
                lng: Double,
                term: String,
                uniqueId: String? = nil)
    {
        self.lat = lat
        self.lng = lng
        self.term = term
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case lat
        case lng
        case term
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat, forKey: .lat)
        try? container.encode(lng, forKey: .lng)
        try? container.encode(term, forKey: .term)
    }
}
