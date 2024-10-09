//
// RolesRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct RolesRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let userRoles: [UserRoleRequest]
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(userRoles: [UserRoleRequest], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.userRoles = userRoles
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    internal init(userRoles: [UserRoleRequest], threadId: Int, uniqueId: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.userRoles = userRoles
        self.threadId = threadId
        self.uniqueId = uniqueId
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case userRoles
        case threadId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userRoles, forKey: .userRoles)
        try container.encode(self.threadId, forKey: .threadId)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
