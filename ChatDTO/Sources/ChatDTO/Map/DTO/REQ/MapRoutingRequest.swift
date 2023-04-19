//
// MapRoutingRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore

public struct Coordinate: Codable {
    public let lat: Double
    public let lng: Double

    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public final class MapRoutingRequest: UniqueIdManagerRequest, Encodable {
    public var alternative: Bool = true
    private let destination: Coordinate
    private let origin: Coordinate

    public init(alternative: Bool?, origin: Coordinate, destination: Coordinate, uniqueId: String? = nil) {
        self.alternative = alternative ?? true
        self.destination = origin
        self.origin = destination
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case alternative
        case origin
        case destination
    }

    public func encode(to encoder: Encoder) throws {
        var continer = encoder.container(keyedBy: CodingKeys.self)
        try? continer.encode("\(origin.lat),\(origin.lng)", forKey: .origin)
        try? continer.encode("\(destination.lat),\(destination.lng)", forKey: .destination)
        try? continer.encode(alternative, forKey: .alternative)
    }
}
