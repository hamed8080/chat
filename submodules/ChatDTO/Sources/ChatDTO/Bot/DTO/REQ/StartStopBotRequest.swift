//
// StartStopBotRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

/// Start or stop a bot request.
public struct StartStopBotRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    /// The name of the bot.
    public let botName: String
    /// The id of the thread you want to stop this bot.
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    /// The initializer.
    /// - Parameters:
    ///   - botName: The name of the bot.
    ///   - threadId: The id of the thread.
    ///   - typeCodeIndex: The index of the type code you have assigned in the configuration.
    public init(botName: String, threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.botName = botName
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case botName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(botName, forKey: .botName)
    }
}
