//
// NotifyDeliveredMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct NotifyDeliveredMessageRequest: Encodable {
    public let messageId: Int
    public let ownerId: Int

    public init(messageId: Int, ownerId: Int) {
        self.messageId = messageId
        self.ownerId = ownerId
    }
}
