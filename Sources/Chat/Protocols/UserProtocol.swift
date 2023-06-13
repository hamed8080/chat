//
// UserProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation
import Additive

public protocol UserProtocol {

    /// Tell the server user has logged out. This method wil **truncate and delete** all data inside the cache.
    func logOut()

    /// Remove set of roles from a participant.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    func remove(_ request: RolesRequest)

    /// Remove a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    func remove(_ request: AuditorRequest)

    /// Send Status ping.
    /// - Parameter request: Send type of ping.
    func send(_ request: SendStatusPingRequest)

    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    func set(_ request: UpdateChatProfile)

    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    func userInfo(_ request: UserInfoRequest)

    /// Set a set of roles to a participant of a thread.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    func set(_ request: RolesRequest)

    /// Set a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    func set(_ request: AuditorRequest)

    /// Get the roles of the current user in a thread.
    /// - Parameters:
    ///   - request: A request that contains a threadId.
    func currentUserRoles(_ request: GeneralSubjectIdRequest)
}

protocol InternalUserProtocol {
    /// A timer for retrieving the ``User`` object to make the ``ChatState/chatReady``.
    var requestUserTimer: TimerProtocol { get set }

    /// Number of retry count to retrieve the user.
    var userRetrycount: Int { get set }

    /// Max number of retry to fetch user object.
    var maxUserRetryCount: Int { get }
}
