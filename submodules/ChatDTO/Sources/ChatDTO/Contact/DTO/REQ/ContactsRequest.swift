//
// ContactsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public enum ContactsRequestOrdering: String, Sendable, Encodable {
    case asc = "asc"
    case desc = "desc"
}

public struct ContactsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var size: Int = 25
    public var offset: Int = 0
    // use in cashe
    public let id: Int? // contact id to client app can query and find a contact in cache core data with id
    public let cellphoneNumber: String?
    public let firstName: String?
    public let lastName: String?
    public let userName: String?
    public let email: String?
    public let coreUserId: Int?
    public let order: String?
    public var summery: Bool?
    public let uniqueId: String
    public var q: String?
    public var metadata: String?
    public var isConnectedToUser: Bool?
    public var linkedUserId: Int?
    public var typeCodeIndex: Index
    public var ownerId: Int?
    public var orderByFirstName: ContactsRequestOrdering?
    public var orderByLastName: ContactsRequestOrdering?
    public var orderById: ContactsRequestOrdering?
    private var typeCode: String?
    
    public init(id: Int? = nil,
                count: Int = 25,
                cellphoneNumber: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil,
                userName: String? = nil,
                email: String? = nil,
                coreUserId: Int? = nil,
                offset: Int = 0,
                order: Ordering? = nil,
                summery: Bool? = nil,
                ownerId: Int? = nil,
                q: String? = nil,
                metadata: String? = nil,
                isConnectedToUser: Bool? = nil,
                linkedUserId: Int? = nil,
                targetUserId: Int? = nil,
                orderByFirstName: ContactsRequestOrdering? = nil,
                orderByLastName: ContactsRequestOrdering? = nil,
                orderById: ContactsRequestOrdering? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        size = count
        self.offset = offset
        self.id = id
        self.cellphoneNumber = cellphoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.email = email
        self.order = order?.rawValue ?? nil
        self.summery = summery
        self.coreUserId = coreUserId
        self.uniqueId = UUID().uuidString
        self.q = q
        self.metadata = metadata
        self.isConnectedToUser = isConnectedToUser
        self.typeCodeIndex = typeCodeIndex
        self.linkedUserId = linkedUserId
        self.ownerId = ownerId
        self.orderByFirstName = orderByFirstName
        self.orderByLastName = orderByLastName
        self.orderById = orderById
    }
    
    private enum CodingKeys: String, CodingKey {
        case size
        case offset
        case id
        case cellphoneNumber
        case firstName
        case lastName
        case email
        case order
        case summery
        case coreUserId
        case username
        case typeCode
        case ownerId
        case q
        case metadata
        case isConnectedToUser
        case linkedUserId
        case orderByFirstName
        case orderByLastName
        case orderById
    }
    
    mutating public func setTypeCode(typeCode: String?) {
        self.typeCode = typeCode
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(size, forKey: .size)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(id, forKey: .id)
        try? container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(firstName, forKey: .firstName)
        try? container.encodeIfPresent(lastName, forKey: .lastName)
        try? container.encodeIfPresent(userName, forKey: .username)
        try? container.encodeIfPresent(email, forKey: .email)
        try? container.encodeIfPresent(coreUserId, forKey: .coreUserId)
        try? container.encodeIfPresent(order, forKey: .order)
        try? container.encodeIfPresent(summery, forKey: .summery)
        try? container.encodeIfPresent(typeCode, forKey: .typeCode)
        try? container.encodeIfPresent(ownerId, forKey: .ownerId)
        try? container.encodeIfPresent(q, forKey: .q)
        try? container.encodeIfPresent(metadata, forKey: .metadata)
        try? container.encodeIfPresent(isConnectedToUser, forKey: .isConnectedToUser)
        try? container.encodeIfPresent(linkedUserId, forKey: .linkedUserId)
        try? container.encodeIfPresent(orderByFirstName, forKey: .orderByFirstName)
        try? container.encodeIfPresent(orderByLastName, forKey: .orderByLastName)
        try? container.encodeIfPresent(orderById, forKey: .orderById)
    }
}
