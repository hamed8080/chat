//
// Roles.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Additive
import Foundation

public enum Roles: String, Codable, SafeDecodable, Identifiable, CaseIterable {
    public var id: Self { self }
    case changeThreadInfo = "CHANGE_THREAD_INFO"
    case postChannelMessage = "POST_CHANNEL_MESSAGE"
    case editMessageOfOthers = "EDIT_MESSAGE_OF_OTHERS"
    case deleteMessageOfOthers = "DELETE_MESSAGE_OF_OTHERS"
    case addNewUser = "ADD_NEW_USER"
    case removeUser = "REMOVE_USER"
    case addRuleToUser = "ADD_RULE_TO_USER"
    case removeRoleFromUser = "REMOVE_ROLE_FROM_USER"
    case readThread = "READ_THREAD"
    case editThread = "EDIT_THREAD"
    case threadAdmin = "THREAD_ADMIN"
    case ownership = "OWNERSHIP"

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}

public enum RoleOperations: String {
    case add
    case remove
}
