//
// GetUserBotsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

/// The request to fetch the list of user bots.
public final class GetUserBotsRequest: UniqueIdManagerRequest, ChatSendable {
    public var chatMessageType: ChatMessageVOTypes = .getUserBots
    public var content: String?

    override public init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }
}
