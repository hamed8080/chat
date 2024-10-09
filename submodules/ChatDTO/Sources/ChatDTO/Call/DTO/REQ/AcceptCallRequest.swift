//
// AcceptCallRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct AcceptCallRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let client: SendClient
    public let callId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(callId: Int, client: SendClient, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        self.client = client
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case client
        case callId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.client, forKey: .client)
        try container.encode(self.callId, forKey: .callId)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
