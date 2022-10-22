//
// BotEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum BotEventTypes {
    case createBot(Bot)
    case botMessage(String?)
    case createBotCommand(BotInfo)
    case removeBotCommand(BotInfo)
    case startBot(String)
    case stopBot(String)
}
