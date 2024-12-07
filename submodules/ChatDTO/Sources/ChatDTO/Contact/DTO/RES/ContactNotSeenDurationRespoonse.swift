//
// ContactNotSeenDurationRespoonse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UserLastSeenDuration: Codable, Sendable {
    public var userId: Int
    public var time: Int

    public init(userId: Int, time: Int) {
        self.userId = userId
        self.time = time
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.time = try container.decode(Int.self, forKey: .time)
    }
}

public struct ContactNotSeenDurationRespoonse: Decodable, Sendable {
    public let notSeenDuration: [UserLastSeenDuration]

    public init(from decoder: Decoder) throws {
        if let unkeyedContainer = try? decoder.singleValueContainer(), let dictionary = try? unkeyedContainer.decode([String: Int?].self) {
            notSeenDuration = dictionary.map { UserLastSeenDuration(userId: Int($0) ?? 0, time: $1 ?? 0) }
        } else {
            notSeenDuration = []
        }
    }
}
