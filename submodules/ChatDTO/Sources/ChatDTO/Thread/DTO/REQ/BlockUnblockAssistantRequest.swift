//
// BlockUnblockAssistantRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct BlockUnblockAssistantRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let assistants: [Assistant]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(assistants: [Assistant], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.assistants = assistants
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case assistants
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.assistants, forKey: .assistants)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
