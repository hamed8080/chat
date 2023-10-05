//
// ReactionProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public protocol ReactionProtocol {
    var inMemoryReaction: InMemoryReactionProtocol { get }
    /// Get the user current reaction on a message.
    /// - Parameters:
    ///   - request: The request that contains a messageId and conversationId.
    func reaction(_ request: UserReactionRequest)

    /// Get the count of each reaction by messageIds.
    /// - Parameters:
    ///   - request: The request that contains a messageIds and conversationId.
    func count(_ request: RactionCountRequest)

    /// Get list of reactions for a messsage with messageId.
    /// - Parameters:
    ///   - uniqueId: The request that contains a messageId and offset and count.
    func get(_ request: RactionListRequest)

    /// Add a reaction to a message.
    /// - Parameters:
    ///   - request: The request that contains messageId and a reaction string for a message.
    func add(_ request: AddReactionRequest)

    /// Replace a reaction of a message to new one.
    /// - Parameters:
    ///   - request: The request that  contains id of message and reaction string for a message.
    func replace(_ request: ReplaceReactionRequest)

    /// Delete a reaction over a message.
    /// - Parameters:
    ///   - request: The request that  contains id of the reactoin.
    func delete(_ request: DeleteReactionRequest)
}
