//
// ReactionProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public protocol ReactionProtocol {
    /// Get list of reactions count for a list of messages.
    /// - Parameters:
    ///   - uniqueId: The request that contains messageId list.
    func get(_ request: RactionListRequest)

    /// Add a reaction to a message.
    /// - Parameters:
    ///   - request: The request that contains messageId and a reaction string for a message.
    func add(_ request: AddReactionRequest)

    /// Replace a reaction of a message to new one.
    /// - Parameters:
    ///   - request: The request that  contains id of message and reaction string for a message.
    func replace(_ request: ReplaceReactionRequest)
}
