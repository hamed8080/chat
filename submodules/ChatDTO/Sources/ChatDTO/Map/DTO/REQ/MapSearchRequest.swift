//
// MapSearchRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapSearchRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let lat: Double
    public let lng: Double
    public let term: String
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(lat: Double,
                lng: Double,
                term: String,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.lat = lat
        self.lng = lng
        self.term = term
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
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
