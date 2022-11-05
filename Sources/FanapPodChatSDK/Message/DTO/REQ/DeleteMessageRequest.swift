//
// DeleteMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class DeleteMessageRequest: BaseRequest {
    public let deleteForAll: Bool
    public let messageId: Int

    public init(deleteForAll: Bool? = false,
                messageId: Int,
                uniqueId: String? = nil)
    {
        self.deleteForAll = deleteForAll ?? false
        self.messageId = messageId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case deleteForAll
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deleteForAll, forKey: .deleteForAll)
    }
}
