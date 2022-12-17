//
// MapRoutingResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class MapRoutingResponse: Decodable {
    public var routes: [Route]?

    private enum CodingKeys: String, CodingKey {
        case routes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        routes = try container.decodeIfPresent([Route].self, forKey: .routes) ?? nil
    }
}
