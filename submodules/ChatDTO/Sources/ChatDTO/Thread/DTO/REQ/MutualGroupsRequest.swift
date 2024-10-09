//
// MutualGroupsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct MutualGroupsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let count: Int
    public let offset: Int
    public let toBeUserVO: Invitee
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(toBeUser: Invitee, count: Int = 25, offset: Int = 0, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.count = count
        self.offset = offset
        toBeUserVO = toBeUser
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case toBeUserVO
        case idType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(toBeUserVO, forKey: .toBeUserVO)
    }
}
