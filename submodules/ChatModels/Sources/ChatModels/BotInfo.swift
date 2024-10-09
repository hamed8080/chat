//
// BotInfo.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

/// Bot more information.
public struct BotInfo: Decodable, Hashable {
    /// The name of the bot.
    public var name: String?

    /// The bot userId.
    public var botUserId: Int?

    /// List of commands.
    public var commandList: [String]?

    public init(name: String? = nil, botUserId: Int? = nil, commandList: [String]? = nil) {
        self.name = name
        self.botUserId = botUserId
        self.commandList = commandList
    }
}
