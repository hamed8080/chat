//
// RemoveContactResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22


import Foundation

public struct RemoveContactResponse: Decodable {
    public var deteled: Bool

    private enum CodingKeys: String, CodingKey {
        case result
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deteled = try container.decodeIfPresent(Bool.self, forKey: .result) ?? false
    }

    public init(deteled: Bool) {
        self.deteled = deteled
    }
}
