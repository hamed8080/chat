//
// BotProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol BotProtocol {
    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    func add(_ request: AddBotCommandRequest)

    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    func get(_ request: GetUserBotsRequest)

    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    func create(_ request: CreateBotRequest)

    /// Remove commands from a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    func remove(_ request: RemoveBotCommandRequest)

    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    func start(_ request: StartStopBotRequest)

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    func stop(_ request: StartStopBotRequest)
}
