//
// MessageACK.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// The message acknowledge request/response.
struct MessageACK: Codable {
    /// Message Id that got/received an acknowledgment.
    var messageId: Int64

    /// Initializer for the message acknowledgment.
    public init(messageId: Int64) {
        self.messageId = messageId
    }
}
