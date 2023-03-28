//
// StartStopBotRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

/// Start or stop a bot request.
public final class StartStopBotRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    var chatMessageType: ChatMessageVOTypes = .stopBot
    var subjectId: Int { threadId }
    var content: String? { convertCodableToString() }

    /// The name of the bot.
    public let botName: String

    /// The id of the thread you want to stop this bot.
    public let threadId: Int

    /// The initializer.
    /// - Parameters:
    ///   - botName: The name of the bot.
    ///   - threadId: The id of the thread.
    ///   - uniqueId:  The unique id of request. If you manage the unique id by yourself you should leave this blank, otherwise, you must use it if you need to know what response is for what request.
    public init(botName: String, threadId: Int, uniqueId: String? = nil) {
        self.botName = botName
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case botName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(botName, forKey: .botName)
    }
}
