//
//  Log.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public enum LogEmitter: Int, CaseIterable, Codable, Identifiable {
    public var id: Self { self }
    case internalLog = 0
    case sent = 1
    case received = 2
}

open class Log: Codable, Identifiable, Hashable {
    public static func == (lhs: Log, rhs: Log) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var time: Date?
    public var message: String?
    public var config: ChatConfig?
    public var deviceInfo: DeviceInfo?
    public var level: LogLevel?
    public var id: UUID
    public var type: LogEmitter?

    private enum CodingKeys: String, CodingKey {
        case time
        case level
        case message
        case id
        case config
        case deviceInfo
        case type
    }

    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = UUID(uuidString: try container?.decodeIfPresent(String.self, forKey: .id) ?? "") ?? UUID()
        message = try container?.decodeIfPresent(String.self, forKey: .message)
        config = try container?.decodeIfPresent(ChatConfig.self, forKey: .config)
        deviceInfo = try container?.decodeIfPresent(DeviceInfo.self, forKey: .deviceInfo)
        time = try container?.decodeIfPresent(Date.self, forKey: .time)
        level = try container?.decodeIfPresent(LogLevel.self, forKey: .level)
        type = try container?.decodeIfPresent(LogEmitter.self, forKey: .type)
    }

    public init(
        time: Date = Date(),
        message: String? = nil,
        config: ChatConfig? = nil,
        deviceInfo: DeviceInfo? = nil,
        level: LogLevel? = nil,
        id: UUID = UUID(),
        type: LogEmitter?
    ) {
        self.time = time
        self.message = message
        self.id = id
        self.config = config
        self.deviceInfo = deviceInfo
        self.level = level
        self.type = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(id.uuidString, forKey: .id)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(deviceInfo, forKey: .deviceInfo)
        try container.encodeIfPresent(config, forKey: .config)
        try container.encodeIfPresent(level, forKey: .level)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
