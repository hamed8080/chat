//
// SendAsyncMessageVO.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

public struct SendAsyncMessageVO: Codable {
    public init(content: String, ttl: Int, peerName: String, priority: Int = 1, uniqueId: String? = nil) {
        self.content = content
        self.ttl = ttl
        self.peerName = peerName
        self.priority = priority
        self.uniqueId = uniqueId
    }

    public let content: String
    public let ttl: Int
    public let peerName: String
    public private(set) var priority: Int = 1
    public let uniqueId: String?
}
