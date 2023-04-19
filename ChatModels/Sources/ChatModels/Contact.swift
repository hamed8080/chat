//
//  Contact.swift
//  Chat
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class Contact: Codable, Hashable, Identifiable {
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var blocked: Bool?
    public var cellphoneNumber: String?
    public var email: String?
    public var firstName: String?
    public var hasUser: Bool?
    public var id: Int?
    public var image: String?
    public var lastName: String?
    public var user: User?
    public var notSeenDuration: Int?
    public var time: UInt?
    public var userId: Int?

    public required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked)
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        notSeenDuration = try container.decodeIfPresent(Int.self, forKey: .notSeenDuration)
        time = try container.decodeIfPresent(UInt.self, forKey: .time)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        hasUser = try container.decodeIfPresent(Bool.self, forKey: .hasUser) ?? false
        user = try container.decodeIfPresent(User.self, forKey: .linkedUser)
        if user != nil {
            hasUser = true
        }
    }

    public init(
        blocked: Bool? = nil,
        cellphoneNumber: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        hasUser: Bool? = nil,
        id: Int? = nil,
        image: String? = nil,
        lastName: String? = nil,
        user: User? = nil,
        notSeenDuration: Int? = nil,
        time: UInt? = nil,
        userId: Int? = nil
    ) {
        self.blocked = blocked
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.hasUser = hasUser
        self.id = id
        self.image = image
        self.lastName = lastName
        self.notSeenDuration = notSeenDuration
        self.time = time
        self.userId = userId
        self.user = user
    }

    private enum CodingKeys: String, CodingKey {
        case blocked
        case cellphoneNumber
        case email
        case firstName
        case lastName
        case hasUser
        case id
        case image = "profileImage"
        case linkedUser
        case notSeenDuration
        case time = "timeStamp"
        case userId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(blocked, forKey: .blocked)
        try container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(hasUser, forKey: .hasUser)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(notSeenDuration, forKey: .notSeenDuration)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(userId, forKey: .userId)
    }
}
