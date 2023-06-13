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
    case blockedList(ChatResponse<[Assistant]>)
    case register(ChatResponse<[Assistant]>)
    case block(ChatResponse<[Assistant]>)
    case unblock(ChatResponse<[Assistant]>)
    case deactive(ChatResponse<[Assistant]>)
    case actions(ChatResponse<[AssistantAction]>)
}
