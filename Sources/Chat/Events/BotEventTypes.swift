//
// BotEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum BotEventTypes {
    case bots(ChatResponse<[BotInfo]>)
    case create(ChatResponse<BotInfo>)
    case message(ChatResponse<String?>)
    case addCommand(ChatResponse<BotInfo>)
    case removeCommand(ChatResponse<BotInfo>)
    case start(ChatResponse<String>)
    case stop(ChatResponse<String>)
}
