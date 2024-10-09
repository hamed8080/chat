//
// AuditorRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct AuditorRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let userRoles: [UserRoleRequest]
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(userRoleRequest: UserRoleRequest, threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.userRoles = [userRoleRequest]
        self.threadId =  threadId
        self.uniqueId = UUID().uuidString
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
