//
// UpdateContactRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UpdateContactRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let cellphoneNumber: String
    public let email: String
    public let firstName: String
    public let id: Int
    public let lastName: String
    public let username: String
    // It will change at runtime inside the method
    private var typeCode: String?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(cellphoneNumber: String,
                email: String,
                firstName: String,
                id: Int,
                lastName: String,
                username: String,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.id = id
        self.lastName = lastName
        self.username = username
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    mutating func setTypeCode(typeCode: String?) {
        self.typeCode = typeCode
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case email
        case firstName
        case id
        case lastName
        case username
        case typeCode
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(id, forKey: .id)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(username, forKey: .username)
        try container.encode(typeCode, forKey: .typeCode)
        try container.encode(uniqueId, forKey: .uniqueId)
    }
}
