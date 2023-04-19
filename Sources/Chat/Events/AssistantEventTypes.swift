//
// AssistantEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum AssistantEventTypes {
    case assistants(ChatResponse<[Assistant]>)
    case registerAssistant(ChatResponse<[Assistant]>)
    case blockAssistant(ChatResponse<[Assistant]>)
    case unblockAssistant(ChatResponse<[Assistant]>)
    case deactiveAssistants(ChatResponse<[Assistant]>)
    case assistantActions(ChatResponse<[AssistantAction]>)
}
