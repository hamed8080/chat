//
// FetchContactsRequest.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct FetchContactsRequest: Sendable {
    public var size: Int = 25
    public var offset: Int = 0
    public let id: Int?
    public let cellphoneNumber: String?
    public let email: String?
    public let coreUserId: Int?
    public let order: String?
    public let query: String?
    public var summery: Bool?

    public init(id: Int? = nil,
                count: Int = 50,
                cellphoneNumber: String? = nil,
                email: String? = nil,
                coreUserId: Int? = nil,
                offset: Int = 0,
                order: Ordering? = nil,
                query: String? = nil,
                summery: Bool? = nil)
    {
        size = count
        self.offset = offset
        self.id = id
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.order = order?.rawValue ?? nil
        self.query = query
        self.summery = summery
        self.coreUserId = coreUserId
    }
}
