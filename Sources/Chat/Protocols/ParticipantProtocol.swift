//
// ParticipantProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol ParticipantProtocol {
    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    func add(_ request: AddParticipantRequest)

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    func remove(_ request: RemoveParticipantsRequest)

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    func get(_ request: ThreadParticipantsRequest)

    // Get thread participants.
    ///
    /// It's the same ``Chat/get(_:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    func admins(_ request: ThreadParticipantsRequest)
}
