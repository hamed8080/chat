//
// ChangeThreadTypeRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ChangeThreadTypeRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let uniqueName: String?
    public var threadId: Int
    public var type: ThreadTypes
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int, type: ThreadTypes, uniqueName: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.type = type
        self.threadId = threadId
        self.uniqueName = uniqueName
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case uniqueName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(type, forKey: .type)
        try? container.encodeIfPresent(uniqueName, forKey: .uniqueName)
    }
}
