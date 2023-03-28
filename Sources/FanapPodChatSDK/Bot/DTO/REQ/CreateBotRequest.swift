//
// CreateBotRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

/// Create bot request.
public final class CreateBotRequest: UniqueIdManagerRequest, PlainTextSendable {
    /// The name of the bot you want to create.
    public var botName: String
    var content: String? { botName }
    var chatMessageType: ChatMessageVOTypes = .createBot

    /// Initializer.
    /// - Parameters:
    ///   - botName: The bot name you want to create.
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this blank, otherwise, you must use it if you need to know what response is for what request.
    public init(botName: String, uniqueId: String? = nil) {
        self.botName = botName
        super.init(uniqueId: uniqueId)
    }
}
