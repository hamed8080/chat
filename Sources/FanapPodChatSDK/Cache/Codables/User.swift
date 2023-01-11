//
//  User.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class User: Codable, Hashable, Identifiable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var cellphoneNumber: String?
    public var coreUserId: Int?
    public var email: String?
    public var id: Int?
    public var image: String?
    public var lastSeen: Int?
    public var name: String?
    public var receiveEnable: Bool?
    public var sendEnable: Bool?
    public var username: String?
    public var chatProfileVO: Profile?
    public var ssoId: String?
    public var lastName: String?
    public var firstName: String?
    public var nickname: String?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        lastSeen = try container.decodeIfPresent(Int.self, forKey: .lastSeen)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        receiveEnable = try container.decodeIfPresent(Bool.self, forKey: .receiveEnable)
        sendEnable = try container.decodeIfPresent(Bool.self, forKey: .sendEnable)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        chatProfileVO = try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
        ssoId = try container.decodeIfPresent(String.self, forKey: .ssoId)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    }

    public init(
        cellphoneNumber: String? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        id: Int? = nil,
        image: String? = nil,
        lastSeen: Int? = nil,
        name: String? = nil,
        nickname: String? = nil,
        receiveEnable: Bool? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        ssoId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        profile: Profile? = nil
    ) {
        self.cellphoneNumber = cellphoneNumber
        self.coreUserId = coreUserId
        self.email = email
        self.id = id
        self.image = image
        self.lastSeen = lastSeen
        self.name = name
        self.nickname = nickname
        self.receiveEnable = receiveEnable
        self.sendEnable = sendEnable
        self.username = username
        self.ssoId = ssoId
        self.lastName = lastName
        self.firstName = firstName
        chatProfileVO = profile
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case coreUserId
        case email
        case id
        case image
        case lastSeen
        case name
        case receiveEnable
        case sendEnable
        case username
        case chatProfileVO
        case ssoId
        case firstName
        case lastName
        case nickname
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encodeIfPresent(coreUserId, forKey: .coreUserId)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(lastSeen, forKey: .lastSeen)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(nickname, forKey: .nickname)
        try container.encodeIfPresent(receiveEnable, forKey: .receiveEnable)
        try container.encodeIfPresent(sendEnable, forKey: .sendEnable)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(ssoId, forKey: .ssoId)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(chatProfileVO, forKey: .chatProfileVO)
    }
}
