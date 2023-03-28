//
// AddContactRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public final class AddContactRequest: UniqueIdManagerRequest, Encodable {
    public var cellphoneNumber: String?
    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var ownerId: Int?
    public var username: String?
    internal var typeCode: String?

    public init(cellphoneNumber: String? = nil,
                email: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil,
                ownerId: Int? = nil,
                uniqueId: String? = nil)
    {
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.ownerId = ownerId
        username = nil
        super.init(uniqueId: uniqueId)
    }

    /// Add Contact with username
    public init(email: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil,
                ownerId: Int? = nil,
                username: String? = nil,
                uniqueId: String? = nil)
    {
        cellphoneNumber = nil
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.ownerId = ownerId
        self.username = username
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case email
        case firstName
        case lastName
        case ownerId
        case username
        case uniqueId
        case typeCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(ownerId, forKey: .ownerId)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
    }
}
