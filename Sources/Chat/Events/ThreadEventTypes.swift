//
// ThreadEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/16/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum ThreadEventTypes {
    case threads(ChatResponse<[Conversation]>)
    case joined(ChatResponse<Conversation>)
    case closed(ChatResponse<Int>)
    case updatedInfo(ChatResponse<Conversation>)
    case userRoles(ChatResponse<[UserRole]>)
    case left(ChatResponse<User>)
    case mute(ChatResponse<Int>)
    case unmute(ChatResponse<Int>)
    case created(ChatResponse<Conversation>)
    case pin(ChatResponse<Conversation>)
    case unpin(ChatResponse<Conversation>)
    case lastMessageDeleted(ChatResponse<Conversation>)
    case lastMessageEdited(ChatResponse<Conversation>)
    case unreadCount(ChatResponse<[String: Int]>)
    case archive(ChatResponse<Int>)
    case unArchive(ChatResponse<Int>)
    case changedType(ChatResponse<Conversation>)
    case mutual(ChatResponse<[Conversation]>)
    case spammed(ChatResponse<Contact>)
    case isNameAvailable(ChatResponse<PublicThreadNameAvailableResponse>)
    case allUnreadCount(ChatResponse<Int>)
    case deleted(ChatResponse<Participant>)
    /// The participant has been removed by the admin of the conversation.
    case userRemoveFormThread(ChatResponse<Int>)
    case lastSeenMessageUpdated(ChatResponse<LastSeenMessageResponse>)
    case lastActions(ChatResponse<[LastActionInConversation]>)
}
