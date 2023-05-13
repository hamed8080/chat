//
// BotProtocols.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol BotProtocols {
    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addBotCommand(_ request: AddBotCommandRequest, completion: @escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType?)

    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getUserBots(_ request: GetUserBotsRequest, completion: @escaping CompletionType<[BotInfo]>, uniqueIdResult: UniqueIdResultType?)

    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createBot(_ request: CreateBotRequest, completion: @escaping CompletionType<Bot>, uniqueIdResult: UniqueIdResultType?)

    /// Remove commands from a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeBotCommand(_ request: RemoveBotCommandRequest, completion: @escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType?)

    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it starts successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func startBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType?)

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it stopped successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func stopBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType?)
}

/// The default implementation of nil values.
public extension BotProtocols {
    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    func addBotCommand(_ request: AddBotCommandRequest, completion: @escaping CompletionType<BotInfo>) {
        addBotCommand(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    func getUserBots(_ request: GetUserBotsRequest, completion: @escaping CompletionType<[BotInfo]>) {
        getUserBots(request, completion: completion, uniqueIdResult: nil)
    }

    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    ///   - completion: The responser of the request.
    func createBot(_ request: CreateBotRequest, completion: @escaping CompletionType<Bot>) {
        createBot(request, completion: completion, uniqueIdResult: nil)
    }

    /// Remove commands from a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    func removeBotCommand(_ request: RemoveBotCommandRequest, completion: @escaping CompletionType<BotInfo>) {
        removeBotCommand(request, completion: completion, uniqueIdResult: nil)
    }

    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it starts successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func startBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>) {
        startBot(request, completion: completion, uniqueIdResult: nil)
    }

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it stopped successfully.
    func stopBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>) {
        stopBot(request, completion: completion, uniqueIdResult: nil)
    }
}
