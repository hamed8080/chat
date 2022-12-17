//
// Contact.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

//
//  Contact.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//
import Foundation

open class Contact: Codable, Hashable {
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
    public var hasUser: Bool = false
    public var id: Int?
    public var image: String?
    public var lastName: String?
    public var linkedUser: LinkedUser?
    public var notSeenDuration: Int?
    public var timeStamp: UInt?
    public var userId: Int?

    public init(blocked: Bool? = nil,
                cellphoneNumber: String? = nil,
                email: String? = nil,
                firstName: String? = nil,
                hasUser: Bool,
                id: Int? = nil,
                image: String? = nil,
                lastName: String? = nil,
                linkedUser: LinkedUser? = nil,
                notSeenDuration: Int? = nil,
                timeStamp: UInt? = nil,
                userId: Int? = nil)
    {
        self.blocked = blocked
        self.cellphoneNumber = cellphoneNumber
        self.email = email
        self.firstName = firstName
        self.hasUser = hasUser
        self.id = id
        self.image = image
        self.lastName = lastName
        self.linkedUser = linkedUser
        self.notSeenDuration = notSeenDuration
        self.timeStamp = timeStamp
        self.userId = userId
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
        case timeStamp
        case userId
    }

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
        timeStamp = try container.decodeIfPresent(UInt.self, forKey: .timeStamp)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        hasUser = try container.decodeIfPresent(Bool.self, forKey: .hasUser) ?? false
        linkedUser = try container.decodeIfPresent(LinkedUser.self, forKey: .linkedUser)
        if linkedUser != nil {
            hasUser = true
        }
    }
}
