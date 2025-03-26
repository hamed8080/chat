//
// SearchMetadataCriteria+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct SearchMetadataCriteria: Codable, Sendable {
    public var field: String?
    public var `is`: String? // can be used for string and number
    public var has: String?
    public var gt: String?
    public var gte: String?
    public var lt: String?
    public var lte: String?
    public var and: [SearchMetadataCriteria]?
    public var or: [SearchMetadataCriteria]?
    public var not: [SearchMetadataCriteria]?
    public var isNumber: Bool?

    public init(field: String? = nil,
                is: String? = nil,
                has: String? = nil,
                gt: String? = nil,
                gte: String? = nil,
                lt: String? = nil,
                lte: String? = nil,
                and: [SearchMetadataCriteria]? = nil,
                or: [SearchMetadataCriteria]? = nil,
                not: [SearchMetadataCriteria]? = nil,
                isNumber: Bool? = nil)
    {
        self.field = field
        self.is = `is`
        self.has = has
        self.gt = gt
        self.gte = gte
        self.lt = lt
        self.lte = lte
        self.and = and
        self.or = or
        self.not = not
        self.isNumber = isNumber
    }
}
