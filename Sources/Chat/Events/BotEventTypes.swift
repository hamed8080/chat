//
// BotEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import Foundation

public enum BotEventTypes {
    case createBot(ChatResponse<BotInfo>)
    case botMessage(ChatResponse<String?>)
    case createBotCommand(ChatResponse<BotInfo>)
    case removeBotCommand(ChatResponse<BotInfo>)
    case startBot(ChatResponse<String>)
    case stopBot(ChatResponse<String>)
}
