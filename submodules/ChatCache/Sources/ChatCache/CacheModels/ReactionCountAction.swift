//
// ReactionCountAction.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public enum ReactionCountAction: Sendable {
    case add
    case delete
    case replace
}

public struct CacheReactionCountModel: Sendable {
    public let action: ReactionCountAction
    public let messageId: Int
    public let myUserId: Int
    public var reaction: Reaction?
    public let oldSticker: Sticker?
    
    public init(action: ReactionCountAction, messageId: Int, reaction: Reaction? = nil, oldSticker: Sticker? = nil, myUserId: Int) {
        self.action = action
        self.messageId = messageId
        self.reaction = reaction
        self.oldSticker = oldSticker
        self.myUserId = myUserId
    }
}
