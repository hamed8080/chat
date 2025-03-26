//
// ContactsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ContactsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var size: Int = 25
    public var offset: Int = 0
    // use in cashe
    public let id: Int? // contact id to client app can query and find a contact in cache core data with id
    public let cellphoneNumber: String?
    public let userName: String?
    public let email: String?
    public let coreUserId: Int?
    public let order: String?
    public let query: String?
    public var summery: Bool?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(id: Int? = nil,
                count: Int = 25,
                cellphoneNumber: String? = nil,
                userName: String? = nil,
                email: String? = nil,
                coreUserId: Int? = nil,
                offset: Int = 0,
                order: Ordering? = nil,
                query: String? = nil,
                summery: Bool? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        size = count
        self.offset = offset
        self.id = id
        self.cellphoneNumber = cellphoneNumber
        self.userName = userName
        self.email = email
        self.order = order?.rawValue ?? nil
        self.query = query
        self.summery = summery
        self.coreUserId = coreUserId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case size
        case offset
        case id
        case cellphoneNumber
        case email
        case order
        case query
        case summery
        case coreUserId
        case username
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(id, forKey: .id)
        try? container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(userName, forKey: .username)
        try? container.encodeIfPresent(email, forKey: .email)
        try? container.encodeIfPresent(coreUserId, forKey: .coreUserId)
        try? container.encodeIfPresent(order, forKey: .order)
        try? container.encodeIfPresent(summery, forKey: .summery)
        try? container.encodeIfPresent(query, forKey: .query)
    }
}
