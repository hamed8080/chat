//
// SystemEventMessageModel.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
import ChatModels

public struct SystemEventMessageModel: Codable {
    public let coreUserId: Int64

    /// System message type.
    public let smt: SMT

    public let userId: Int
    public let ssoId: String
    public let user: String
}
