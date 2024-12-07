//
// Bot.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

/// A bot object.
public struct Bot: Codable, Hashable, Sendable {
    ///
    public var apiToken: String?

    ///
    public var thing: Thing?

    private enum CodingKeys: String, CodingKey {
        case apiToken
        case thing = "thingVO"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(apiToken, forKey: .apiToken)
        try container.encodeIfPresent(thing, forKey: .thing)
    }

    public init(apiToken: String? = nil, thing: Thing? = nil) {
        self.apiToken = apiToken
        self.thing = thing
    }
}
