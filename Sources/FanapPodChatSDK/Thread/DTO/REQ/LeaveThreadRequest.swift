//
// LeaveThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class LeaveThreadRequest: BaseRequest {
    public let threadId: Int
    public let clearHistory: Bool?

    public init(threadId: Int, clearHistory: Bool? = false, uniqueId: String? = nil) {
        self.clearHistory = clearHistory
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case clearHistory
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(clearHistory, forKey: .clearHistory)
    }
}
