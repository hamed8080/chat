//
// AssistantEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum AssistantEventTypes {
    case assistants(_ assistants: [Assistant])
    case registerAssistant(_ assistants: [Assistant])
    case blockAssistant(_ assistants: [Assistant])
    case unblockAssistant(_ assistants: [Assistant])
    case deactiveAssistants(_ assistants: [Assistant])
    case assistantActions(_ actions: [AssistantAction])
}
