//
// NotSeenDurationRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct NotSeenDurationRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let userIds: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(userIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.userIds = userIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case userIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(userIds, forKey: .userIds)
    }
}
