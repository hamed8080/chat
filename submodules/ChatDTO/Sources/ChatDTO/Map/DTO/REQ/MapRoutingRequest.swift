//
// Coordinate.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22


import Foundation

public struct Coordinate: Codable, Sendable {
    public let lat: Double
    public let lng: Double

    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public struct MapRoutingRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var alternative: Bool = true
    private let destination: Coordinate
    private let origin: Coordinate
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(alternative: Bool?, origin: Coordinate, destination: Coordinate, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.alternative = alternative ?? true
        self.destination = origin
        self.origin = destination
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
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
