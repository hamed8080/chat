//
// RemoveContactsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct RemoveContactsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let contactId: Int
    private var typeCode: String?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(contactId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.contactId = contactId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    mutating public func setTypeCode(typeCode: String?) {
        self.typeCode = typeCode
    }

    private enum CodingKeys: String, CodingKey {
        case contactId = "id"
        case typeCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(contactId, forKey: .contactId)
        try? container.encodeIfPresent(typeCode, forKey: .typeCode)
    }
}
