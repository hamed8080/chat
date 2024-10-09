//
// SystemEventMessageModel.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct SystemEventMessageModel: Codable {
    public let coreUserId: Int64
    /// System message type.
    public let smt: SMT
    public let userId: Int
    public let ssoId: String
    public let user: String

    public init(coreUserId: Int64, smt: SMT, userId: Int, ssoId: String, user: String) {
        self.coreUserId = coreUserId
        self.smt = smt
        self.userId = userId
        self.ssoId = ssoId
        self.user = user
    }

    private enum CodingKeys: CodingKey {
        case coreUserId
        case smt
        case userId
        case ssoId
        case user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coreUserId = try container.decode(Int64.self, forKey: .coreUserId)
        self.smt = try container.decode(SMT.self, forKey: .smt)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.ssoId = try container.decode(String.self, forKey: .ssoId)
        self.user = try container.decode(String.self, forKey: .user)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.coreUserId, forKey: .coreUserId)
        try container.encode(self.smt, forKey: .smt)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.ssoId, forKey: .ssoId)
        try container.encode(self.user, forKey: .user)
    }
}
