//
// BotInfo.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

/// Bot more information.
public final class BotInfo: Decodable {
    /// The name of the bot.
    public var name: String?

    /// The bot userId.
    public var botUserId: Int?

    /// List of commands.
    public var commandList: [String]?
}
