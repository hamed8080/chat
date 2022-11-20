//
// BotCommandsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// The request to fetch the list of user bots.
public class BotCommandsRequest: UniqueIdManagerRequest, ChatSendable {
    var chatMessageType: ChatMessageVOTypes = .botCommands
    var content: String?

    override public init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }
}

