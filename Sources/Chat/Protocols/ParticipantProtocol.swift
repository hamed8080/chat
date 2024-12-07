//
// ParticipantProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

@ChatGlobalActor
public protocol ParticipantProtocol: AnyObject {
    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    func add(_ request: AddParticipantRequest)

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    func remove(_ request: RemoveParticipantRequest)

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    func get(_ request: ThreadParticipantRequest)

    /// Add admin role to participants of a thread.
    /// - Parameters:
    ///   - request: List of users.
    func addAdminRole(_ request: AdminRoleRequest)

    /// Remove the admin role to participants of a thread.
    /// - Parameters:
    ///   - request: List of users.
    func removeAdminRole(_ request: AdminRoleRequest)
}
