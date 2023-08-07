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
    ///
    /// It will only fetch activated assistants, not deactivated ones.
    func get(_ request: AssistantsRequest)

    /// Get a history of assitant actions.
    func history(_ request: AssistantsHistoryRequest)

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
    ///
    /// By deactivating an assistant, you will not receive it in the get method. However, it remains untouched in conversations that have already been added to; it simply will not be added in future conversations.
    func deactive(_ request: DeactiveAssistantRequest)

    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    func register(_ request: RegisterAssistantsRequest)
}
