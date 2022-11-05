//
// NotSeenDurationRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class NotSeenDurationRequest: BaseRequest {
    public let userIds: [Int]

    public init(userIds: [Int], uniqueId: String? = nil) {
        self.userIds = userIds
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case userIds
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(userIds, forKey: .userIds)
    }
}
