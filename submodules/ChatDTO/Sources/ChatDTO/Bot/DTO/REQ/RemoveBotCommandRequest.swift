//
// RemoveBotCommandRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

/// Remove the bot commands request.
public struct RemoveBotCommandRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    /// The bot name.
    public let botName: String
    public let commandList: [String]
    public let uniqueId: String
    public var typeCodeIndex: Index

    /// The initializer.
    /// - Parameters:
    ///   - botName: The bot name.
    ///   - commandList: List of commands.
    ///   - typeCodeIndex: The index of the type code you have assigned in the configuration.
    public init(botName: String, commandList: [String] = [], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.botName = botName
        var arr: [String] = []
        for command in commandList {
            if command.first == "/" {
                arr.append(command)
            } else {
                arr.append("/\(command)")
            }
        }
        self.commandList = arr
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case botName
        case commandList
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commandList, forKey: .commandList)
        try container.encode(botName, forKey: .botName)
    }
}
