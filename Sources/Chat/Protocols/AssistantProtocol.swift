//
// AssistantProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol AssistantProtocol {
    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    func get(_ request: AssistantsRequest)

    /// Get a history of assitant actions.
    func history()

    /// Block assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to block them.
    func block(_ request: BlockUnblockAssistantRequest)

    /// UNBlock assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to unblock them.
    func unblock(_ request: BlockUnblockAssistantRequest)

    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    func blockedList(_ request: BlockedAssistantsRequest)

    /// Deactivate assistants.
    /// - Parameters:
    ///   - request: A request that contains a list of activated assistants.
    func deactive(_ request: DeactiveAssistantRequest)

    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    func register(_ request: RegisterAssistantsRequest)
}
