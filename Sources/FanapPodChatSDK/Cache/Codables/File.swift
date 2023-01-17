//
//  File.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class File: Codable, Identifiable, Hashable {
    public static func == (lhs: File, rhs: File) -> Bool {
        lhs.hashCode == rhs.hashCode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashCode)
    }

    var hashCode: String?
    var name: String?
    var size: Int?
    var type: String?

    private enum CodingKeys: String, CodingKey {
        case hashCode
        case name
        case size
        case type
    }

    public init(
        hashCode: String? = nil,
        name: String? = nil,
        size: Int? = nil,
        type: String? = nil
    ) {
        self.hashCode = hashCode
        self.name = name
        self.size = size
        self.type = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hashCode, forKey: .hashCode)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
