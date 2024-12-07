//
// MapReverseRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapReverseRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let lat: Double
    public let lng: Double
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(lat: Double, lng: Double, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.lat = lat
        self.lng = lng
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
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
