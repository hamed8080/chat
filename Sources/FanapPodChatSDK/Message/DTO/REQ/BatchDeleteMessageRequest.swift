//
// BatchDeleteMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class BatchDeleteMessageRequest: BaseRequest {
    let threadId: Int
    let deleteForAll: Bool
    let messageIds: [Int]
    let uniqueIds: [String]

    public init(threadId: Int, messageIds: [Int], deleteForAll: Bool = false, uniqueIds: [String]? = nil, uniqueId: String? = nil) {
        self.threadId = threadId
        self.deleteForAll = deleteForAll
        if let uniqueIds = uniqueIds {
            self.uniqueIds = uniqueIds
        } else {
            var generatedUniqeIds: [String] = []
            for _ in 0 ..< messageIds.count {
                generatedUniqeIds.append(UUID().uuidString)
            }
            self.uniqueIds = generatedUniqeIds
        }
        self.messageIds = messageIds
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case deleteForAll
        case ids
        case uniqueIds
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageIds, forKey: .ids)
        try container.encode(deleteForAll, forKey: .deleteForAll)
        try container.encode(uniqueIds, forKey: .uniqueIds)
    }
}
