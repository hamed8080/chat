//
//  Image.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class Image: Codable, Hashable, Identifiable {
    public static func == (lhs: Image, rhs: Image) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id = UUID()
    public var actualHeight: Int?
    public var actualWidth: Int?
    public var hashCode: String?
    public var height: Int?
    public var name: String?
    public var size: Int?
    public var width: Int?

    private enum CodingKeys: String, CodingKey {
        case actualHeight
        case actualWidth
        case hashCode
        case height
        case name
        case size
        case width
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actualWidth = try container.decodeIfPresent(Int.self, forKey: .actualWidth)
        actualHeight = try container.decodeIfPresent(Int.self, forKey: .actualHeight)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        width = try container.decodeIfPresent(Int.self, forKey: .width)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        hashCode = try container.decodeIfPresent(String.self, forKey: .hashCode)
    }

    public init(
        actualWidth: Int? = nil,
        actualHeight: Int? = nil,
        height: Int? = nil,
        width: Int? = nil,
        size: Int? = nil,
        name: String? = nil,
        hashCode: String? = nil
    ) {
        self.actualWidth = actualWidth
        self.actualHeight = actualHeight
        self.height = height
        self.width = width
        self.size = size
        self.name = name
        self.hashCode = hashCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(actualWidth, forKey: .actualWidth)
        try container.encodeIfPresent(actualHeight, forKey: .actualHeight)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(hashCode, forKey: .hashCode)
    }
}
