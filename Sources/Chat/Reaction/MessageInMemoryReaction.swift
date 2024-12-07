//
// MessageInMemoryReaction.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public class MessageInMemoryReaction {
    let messageId: Int
    var currentUserReaction: Reaction?
    var summary: [ReactionCount] = []
    /// All participants reaction to a message.
    var details: [Reaction] = []

    public init(messageId: Int) {
        self.messageId = messageId
    }

    public func appendOrReplaceDetail(reactions: [Reaction]) {
        reactions.forEach { reaction in
            if let index = self.details.firstIndex(where: {$0.id == reaction.id}) {
                details[index] = reaction
            } else {
                details.append(reaction)
            }
        }
    }

    public func addOrReplaceSummaryCount(sticker: Sticker) {
        if let index = summary.firstIndex(where: { $0.sticker == sticker }) {
            summary[index].count = (summary[index].count ?? 0) + 1
        } else {
            summary.append(.init(sticker: sticker, count: 1))
        }
    }

    public func deleteSummaryCount(sticker: Sticker) {
        if let index = summary.firstIndex(where: { $0.sticker == sticker }) {
            summary[index].count = max(0, (summary[index].count ?? 0) - 1)
            if summary[index].count ?? 0 == 0 {
                summary.remove(at: index)
            }
        }
    }

    var copy: ReactionInMemoryCopy { .init(messageId: messageId, currentUserReaction: currentUserReaction, summary: summary, details: details) }
}

public struct ReactionInMemoryCopy: Sendable {
    public let messageId: Int
    public var currentUserReaction: Reaction?
    public var summary: [ReactionCount] = []
    /// All participants reaction to a message.
    public var details: [Reaction] = []

    public init(messageId: Int, currentUserReaction: Reaction? = nil, summary: [ReactionCount] = [], details: [Reaction] = []) {
        self.messageId = messageId
        self.currentUserReaction = currentUserReaction
        self.summary = summary
        self.details = details
    }
}
