//
// Log.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Log: Codable, Identifiable, Hashable {
    public static func == (lhs: Log, rhs: Log) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var prefix: String?
    public var time: Date?
    public var message: String?
    public var userInfo: [String: String]?
    public var level: LogLevel?
    public var id: UUID
    public var type: LogEmitter?

    private enum CodingKeys: String, CodingKey {
        case prefix
        case time
        case level
        case message
        case id
        case type
        case userInfo
    }

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        prefix = try container?.decodeIfPresent(String.self, forKey: .prefix)
        id = UUID(uuidString: try container?.decodeIfPresent(String.self, forKey: .id) ?? "") ?? UUID()
        message = try container?.decodeIfPresent(String.self, forKey: .message)
        time = try container?.decodeIfPresent(Date.self, forKey: .time)
        level = try container?.decodeIfPresent(LogLevel.self, forKey: .level)
        type = try container?.decodeIfPresent(LogEmitter.self, forKey: .type)
        userInfo = try container?.decodeIfPresent([String: String].self, forKey: .userInfo)
    }

    public init(
        prefix: String? = nil,
        time: Date = Date(),
        message: String? = nil,
        level: LogLevel? = nil,
        id: UUID = UUID(),
        type: LogEmitter?,
        userInfo: [String: String]? = nil
    ) {
        self.prefix = prefix
        self.time = time
        self.message = message
        self.id = id
        self.level = level
        self.type = type
        self.userInfo = userInfo
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(prefix, forKey: .prefix)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(id.uuidString, forKey: .id)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(userInfo, forKey: .userInfo)
    }
}
