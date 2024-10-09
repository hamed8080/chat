//
// SearchMetadataCriteria.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct SearchMetadataCriteria: Codable {
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

    private enum CodingKeys: CodingKey {
        case field
        case `is`
        case has
        case gt
        case gte
        case lt
        case lte
        case and
        case or
        case not
        case isNumber
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.field, forKey: .field)
        try container.encodeIfPresent(self.is, forKey: .is)
        try container.encodeIfPresent(self.has, forKey: .has)
        try container.encodeIfPresent(self.gt, forKey: .gt)
        try container.encodeIfPresent(self.gte, forKey: .gte)
        try container.encodeIfPresent(self.lt, forKey: .lt)
        try container.encodeIfPresent(self.lte, forKey: .lte)
        try container.encodeIfPresent(self.and, forKey: .and)
        try container.encodeIfPresent(self.or, forKey: .or)
        try container.encodeIfPresent(self.not, forKey: .not)
        try container.encodeIfPresent(self.isNumber, forKey: .isNumber)
    }
}
