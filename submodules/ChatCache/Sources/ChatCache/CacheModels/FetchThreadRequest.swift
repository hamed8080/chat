//
// FetchThreadRequest.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct FetchThreadRequest: Sendable {
    public let count: Int
    public let offset: Int
    public var title: String?
    public var description: String?
    public let new: Bool?
    public let archived: Bool?
    public let threadIds: [Int]?
    public let creatorCoreUserId: Int?
    public let partnerCoreUserId: Int?
    public let partnerCoreContactId: Int?
    public var metadataCriteria: String?
    public var isGroup: Bool?
    public var type: Int?
    public let uniqueId: String?

    public init(count: Int = 25,
                offset: Int = 0,
                title: String? = nil,
                description: String? = nil,
                new: Bool? = nil,
                isGroup: Bool? = nil,
                type: Int? = nil,
                archived: Bool? = nil,
                threadIds: [Int]? = nil,
                creatorCoreUserId: Int? = nil,
                partnerCoreUserId: Int? = nil,
                partnerCoreContactId: Int? = nil,
                metadataCriteria: String? = nil,
                uniqueId: String? = nil)
    {
        self.count = count
        self.offset = offset
        self.title = title
        self.description = description
        self.metadataCriteria = metadataCriteria
        self.new = new
        self.isGroup = isGroup
        self.type = type
        self.archived = archived
        self.threadIds = threadIds
        self.creatorCoreUserId = creatorCoreUserId
        self.partnerCoreUserId = partnerCoreUserId
        self.partnerCoreContactId = partnerCoreContactId
        self.uniqueId = uniqueId
    }

}
