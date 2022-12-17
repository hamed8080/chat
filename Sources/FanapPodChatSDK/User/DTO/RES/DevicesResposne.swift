//
// DevicesResposne.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

struct Device: Decodable {
    var agent: String?
    var browser: String?
    var current: Bool?
    var deviceType: String?
    var id: Int?
    var ip: String?
    var language: String?
    var lastAccessTime: Int?
    var os: String?
    var osVersion: String?
    var uid: String?
}

class DevicesResposne: Decodable {
    let devices: [Device]?
    let offset: Int?
    let size: Int?
    let total: Int?
}
