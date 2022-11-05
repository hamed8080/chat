//
// BotInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// Bot more information.
public class BotInfo: Decodable {
    /// The name of the bot.
    public var name: String?

    /// The bot userId.
    public var botUserId: Int?

    /// List of commands.
    public var commandList: [String]?
}
