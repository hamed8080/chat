//
// Roles.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum Roles: String, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case changeThreadInfo = "change_thread_info"
    case postChannelMessage = "post_channel_message"
    case editMessageOfOthers = "edit_message_of_others"
    case deleteMessageOfOthers = "delete_message_of_others"
    case addNewUser = "add_new_user"
    case removeUser = "remove_user"
    case addRuleToUser = "add_rule_to_user"
    case removeRoleFromUser = "remove_role_from_user"
    case readThread = "read_thread"
    case editThread = "edit_thread"
    case threadAdmin = "thread_admin"
    case ownership = "ownership"
    case callAdmin = "call_admin"

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }

    public static var adminRoles: [Roles] {
        Roles.allCases.filter{ $0 != .callAdmin && $0 != .unknown && $0 != .changeThreadInfo }
    }
}

public enum RoleOperations: String {
    case add
    case remove
}
