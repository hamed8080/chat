//
// AddUserToUserGroupRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct AddUserToUserGroupRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public var conversationId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(conversationId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.conversationId = conversationId
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = UUID().uuidString
    }
}
