//
// ThreadsUnreadCountRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ThreadsUnreadCountRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let threadIds: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadIds = threadIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public func encode(to _: Encoder) throws {}
}
