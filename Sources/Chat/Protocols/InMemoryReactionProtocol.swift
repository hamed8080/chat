//
// InMemoryReactionProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels

public protocol InMemoryReactionProtocol {
    /// Return current user reaction for a message if there is any.
    func currentReaction(_ messageId: Int) -> Reaction?

    /// Return list of stickers and count per messageId.
    func summary(for messageId: Int) -> [ReactionCount]

    /// Return list of participants reaction for each message.
    func participants(messageId: Int, sticker: Sticker) -> [Reaction]
}
