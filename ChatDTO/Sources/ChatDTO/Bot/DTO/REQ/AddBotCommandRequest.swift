//
// AddBotCommandRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class AddBotCommandRequest: UniqueIdManagerRequest, ChatSendable {
    public var chatMessageType: ChatMessageVOTypes = .defineBotCommand
    public var content: String?

    /// The bot name.
    public let botName: String
    public var commandList: [String] = []

    /// The initializer.
    /// - Parameters:
    ///   - botName: The bot name.
    ///   - commandList: List of commands.
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this blank, otherwise, you must use it if you need to know what response is for what request.
    public init(botName: String, commandList: [String], uniqueId: String? = nil) {
        self.botName = botName
        for command in commandList {
            if command.first == "/" {
                self.commandList.append(command)
            } else {
                self.commandList.append("/\(command)")
            }
        }
        super.init(uniqueId: uniqueId)
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
