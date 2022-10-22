//
// SystemEventMessageModel.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct SystemEventMessageModel: Codable {
    public let coreUserId: Int64

    /// System message type.
    public let smt: SMT

    public let userId: Int
    public let ssoId: String
    public let user: String
}
