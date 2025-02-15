//
// ReactionProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

@ChatGlobalActor
public protocol ReactionProtocol: AnyObject {
    /// Get the user current reaction on a message.
    /// - Parameters:
    ///   - request: The request that contains a messageId and conversationId.
    func reaction(_ request: UserReactionRequest)

    /// Get the count of each reaction by messageIds.
    /// - Parameters:
    ///   - request: The request that contains a messageIds and conversationId.
    func count(_ request: ReactionCountRequest)

    /// Get list of participants and their reaction to a messsage with messageId.
    /// - Parameters:
    ///   - uniqueId: The request that contains a messageId and offset and count.
    func get(_ request: ReactionListRequest)

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

    /// Get list of the allowed reactions for a conversation.
    /// - Parameters:
    ///   - request: A request that contains a conversationId.
    func allowedReactions(_ request: ConversationAllowedReactionsRequest)

    /// Customize list sticker(emoji) you want to set for a group/channel.
    /// - Parameters:
    ///   - request: A conversation id is needed along with status you want to shift to.
    ///   - allowedReactions is optional if you want to reaction and don't touch what you have set before.
    func customizeReactions(_ request: ConversationCustomizeReactionsRequest)
}
