//
// Device.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Device: Decodable {
    public var agent: String?
    public var browser: String?
    public var current: Bool?
    public var deviceType: String?
    public var id: Int?
    public var ip: String?
    public var language: String?
    public var lastAccessTime: Int?
    public var os: String?
    public var osVersion: String?
    public var uid: String?

    private enum CodingKeys: CodingKey {
        case agent
        case browser
        case current
        case deviceType
        case id
        case ip
        case language
        case lastAccessTime
        case os
        case osVersion
        case uid
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.agent = try container.decodeIfPresent(String.self, forKey: .agent)
        self.browser = try container.decodeIfPresent(String.self, forKey: .browser)
        self.current = try container.decodeIfPresent(Bool.self, forKey: .current)
        self.deviceType = try container.decodeIfPresent(String.self, forKey: .deviceType)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.lastAccessTime = try container.decodeIfPresent(Int.self, forKey: .lastAccessTime)
        self.os = try container.decodeIfPresent(String.self, forKey: .os)
        self.osVersion = try container.decodeIfPresent(String.self, forKey: .osVersion)
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid)
    }

    public init(agent: String? = nil, browser: String? = nil, current: Bool? = nil, deviceType: String? = nil, id: Int? = nil, ip: String? = nil, language: String? = nil, lastAccessTime: Int? = nil, os: String? = nil, osVersion: String? = nil, uid: String? = nil) {
        self.agent = agent
        self.browser = browser
        self.current = current
        self.deviceType = deviceType
        self.id = id
        self.ip = ip
        self.language = language
        self.lastAccessTime = lastAccessTime
        self.os = os
        self.osVersion = osVersion
        self.uid = uid
    }
}

public struct DevicesResposne: Decodable {
    public let devices: [Device]?
    public let offset: Int?
    public let size: Int?
    public let total: Int?

    private enum CodingKeys: CodingKey {
        case devices
        case offset
        case size
        case total
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.devices = try container.decodeIfPresent([Device].self, forKey: .devices)
        self.offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        self.size = try container.decodeIfPresent(Int.self, forKey: .size)
        self.total = try container.decodeIfPresent(Int.self, forKey: .total)
    }

    public init(devices: [Device]? = nil, offset: Int? = nil, size: Int? = nil, total: Int? = nil) {
        self.devices = devices
        self.offset = offset
        self.size = size
        self.total = total
    }
}
