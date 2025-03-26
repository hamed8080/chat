//
// CacheLastSeenMessageResponse.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct CacheLastSeenMessageResponse: Sendable {
    public let threadId: Int
    public let lastSeenMessageId: Int
    public let lastSeenMessageTime: UInt?
    public let lastSeenMessageNanos: UInt?
    
    public init(threadId: Int, lastSeenMessageId: Int, lastSeenMessageTime: UInt? = nil, lastSeenMessageNanos: UInt? = nil) {
        self.threadId = threadId
        self.lastSeenMessageId = lastSeenMessageId
        self.lastSeenMessageTime = lastSeenMessageTime
        self.lastSeenMessageNanos = lastSeenMessageNanos
    }
}
