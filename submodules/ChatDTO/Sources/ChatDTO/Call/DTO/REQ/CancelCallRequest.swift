//
// CancelCallRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct CancelCallRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let call: Call
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(call: Call, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.call = call
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case call
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.call, forKey: .call)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
