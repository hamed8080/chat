//
// OwnerTypeCode.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct OwnerTypeCode: Codable {
    public var typeCode: String
    public var ownerId: Int?

    public init(typeCode: String, ownerId: Int? = nil) {
        self.typeCode = typeCode
        self.ownerId = ownerId
    }
}
