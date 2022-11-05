//
// UnreadMessageCountRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class UnreadMessageCountRequest: BaseRequest {
    let countMutedThreads: Bool

    public init(countMutedThreads: Bool = false, uniqueId: String? = nil) {
        self.countMutedThreads = countMutedThreads
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case mute
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countMutedThreads, forKey: .mute)
    }
}
