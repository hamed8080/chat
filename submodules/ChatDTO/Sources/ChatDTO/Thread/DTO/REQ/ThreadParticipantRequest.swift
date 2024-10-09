//
// ThreadParticipantRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ThreadParticipantRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public var count: Int
    public var offset: Int
    public var threadId: Int
    public var name: String?
    public var username: String?
    public var cellphoneNumber: String?
    /// If it set to true the request only contains the list of admins of a thread.
    public var admin: Bool = false
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int,
                offset: Int = 0,
                count: Int = 25,
                name: String? = nil,
                admin: Bool = false,
                cellphoneNumber: String? = nil,
                username: String? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.count = count
        self.offset = offset
        self.threadId = threadId
        self.admin = admin
        self.username = username
        self.cellphoneNumber = cellphoneNumber
        self.name = name
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case admin
        case name
        case cellphoneNumber
        case username
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(admin, forKey: .admin)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(username, forKey: .username)
    }
}
