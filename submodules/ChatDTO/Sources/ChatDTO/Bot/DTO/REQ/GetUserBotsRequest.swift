//
// GetUserBotsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

/// The request to fetch the list of user bots.
public struct GetUserBotsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {}
}
