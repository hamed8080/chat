//
// ConversationAllowedReactionsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ConversationAllowedReactionsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let conversationId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(conversationId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }
}
