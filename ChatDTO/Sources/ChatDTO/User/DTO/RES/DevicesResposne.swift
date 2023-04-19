//
// DevicesResposne.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

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
}

public class DevicesResposne: Decodable {
    public let devices: [Device]?
    public let offset: Int?
    public let size: Int?
    public let total: Int?
}
