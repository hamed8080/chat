//
// ThreadsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ThreadsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public var count: Int
    public var offset: Int
    public var name: String?
    public let new: Bool?
    public let archived: Bool?
    public let threadIds: [Int]?
    public let creatorCoreUserId: Int?
    public let partnerCoreUserId: Int?
    public let partnerCoreContactId: Int?
    public var metadataCriteria: String?
    public var isGroup: Bool?
    public var type: ThreadTypes?
    public let uniqueId: String
    /// - summary: If it set to true the result only contains the ids of threads not other properties.
    public let summary: Bool?
    public let cellPhoneNumber: String?
    public let userName: String?
    public let cache: Bool
    public var typeCodeIndex: Index

    public init(count: Int = 25,
                offset: Int = 0,
                name: String? = nil,
                new: Bool? = nil,
                isGroup: Bool? = nil,
                type: ThreadTypes? = nil,
                archived: Bool? = nil,
                threadIds: [Int]? = nil,
                creatorCoreUserId: Int? = nil,
                partnerCoreUserId: Int? = nil,
                partnerCoreContactId: Int? = nil,
                metadataCriteria: String? = nil,
                cellPhoneNumber: String? = nil,
                userName: String? = nil,
                summary: Bool? = nil,
                cache: Bool = true,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0
    )
    {
        self.count = count
        self.offset = offset
        self.name = name
        self.metadataCriteria = metadataCriteria
        self.new = new
        self.isGroup = isGroup
        self.type = type
        self.archived = archived
        self.threadIds = threadIds
        self.creatorCoreUserId = creatorCoreUserId
        self.partnerCoreUserId = partnerCoreUserId
        self.partnerCoreContactId = partnerCoreContactId
        self.cellPhoneNumber = cellPhoneNumber
        self.userName = userName
        self.uniqueId = UUID().uuidString
        self.summary = summary
        self.cache = cache
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case name
        case new
        case archived
        case threadIds
        case creatorCoreUserId
        case partnerCoreUserId
        case partnerCoreContactId
        case metadataCriteria
        case isGroup
        case type
        case summary
        case cellphoneNumber
        case username
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(count, forKey: .count)
        try? container.encode(offset, forKey: .offset)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(new, forKey: .new)
        try? container.encodeIfPresent(threadIds, forKey: .threadIds)
        try? container.encodeIfPresent(creatorCoreUserId, forKey: .creatorCoreUserId)
        try? container.encodeIfPresent(partnerCoreUserId, forKey: .partnerCoreUserId)
        try? container.encodeIfPresent(partnerCoreContactId, forKey: .partnerCoreContactId)
        try? container.encodeIfPresent(metadataCriteria, forKey: .metadataCriteria)
        try? container.encodeIfPresent(archived, forKey: .archived)
        try? container.encodeIfPresent(isGroup, forKey: .isGroup)
        try? container.encodeIfPresent(type, forKey: .type)
        try? container.encodeIfPresent(summary, forKey: .summary)
        try? container.encodeIfPresent(cellPhoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(userName, forKey: .username)
    }
}
