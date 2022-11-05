//
// ChatResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct ChatResponse {
    public var uniqueId: String?
    public var result: Any?
    public var cacheResponse: Any?
    public var error: ChatError?
    public var contentCount: Int = 0
}
