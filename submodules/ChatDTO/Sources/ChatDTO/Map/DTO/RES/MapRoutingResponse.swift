//
// MapRoutingResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapRoutingResponse: Decodable {
    public var routes: [Route]?

    private enum CodingKeys: String, CodingKey {
        case routes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routes = try container.decodeIfPresent([Route].self, forKey: .routes) ?? nil
    }

    public init(routes: [Route]? = nil) {
        self.routes = routes
    }
}
