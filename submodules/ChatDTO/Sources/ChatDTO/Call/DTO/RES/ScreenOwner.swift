//
// ScreenOwner.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct ScreenOwner: Codable, Sendable {
    public let id: Int?
    public let name: String?
    public let image: String?
    
    public init(id: Int?, name: String?, image: String?) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.image, forKey: .image)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}
