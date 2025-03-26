//
// AssistantsHistoryRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AssistantsHistoryRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let count: Int
    public let offset: Int
    public let fromTime: UInt?
    public let toTime: UInt?
    public let actionType: AssistantActionTypes?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(count: Int = 25,
                offset: Int = 0,
                actionType: AssistantActionTypes? = nil,
                fromTime: UInt? = nil,
                toTime: UInt? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0
    ) {
        self.actionType = actionType
        self.fromTime = fromTime
        self.toTime = toTime
        self.count = count
        self.offset = offset
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case actionType
        case fromTime
        case toTime
        case count
        case offset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(offset, forKey: .offset)
        try container.encodeIfPresent(fromTime, forKey: .fromTime)
        try container.encodeIfPresent(toTime, forKey: .toTime)
        try container.encodeIfPresent(actionType, forKey: .actionType)

    }
}
