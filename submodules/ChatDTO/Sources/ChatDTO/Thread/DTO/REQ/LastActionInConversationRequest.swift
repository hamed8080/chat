//
// LastActionInConversationRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct LastActionInConversationRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var ids: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(ids: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.ids = ids
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }
}
