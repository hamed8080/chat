//
// ContactEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum ContactEventTypes: Sendable {
    case contacts(ChatResponse<[Contact]>)
    case add(ChatResponse<[Contact]>)
    case delete(ChatResponse<[Contact]>, deleted: Bool)
    case blockedList(ChatResponse<[BlockedContactResponse]>)
    case blocked(ChatResponse<BlockedContactResponse>)
    case unblocked(ChatResponse<BlockedContactResponse>)
    case notSeen(ChatResponse<[ContactNotSeenDurationRespoonse]>)
    case contactsLastSeen(ChatResponse<[UserLastSeenDuration]>)
    case synced(ChatResponse<ChatMessage>)
}
