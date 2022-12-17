//
// MapReverseRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class MapReverseRequest: UniqueIdManagerRequest, Encodable {
    public let lat: Double
    public let lng: Double

    public init(lat: Double, lng: Double, uniqueId: String? = nil) {
        self.lat = lat
        self.lng = lng
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case lat
        case lng
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat, forKey: .lat)
        try? container.encode(lng, forKey: .lng)
    }
}
