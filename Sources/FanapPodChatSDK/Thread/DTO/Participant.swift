//
// Participant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

//
//  Participant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//
import Foundation

open class Participant: Codable, Hashable {
    public static func == (lhs: Participant, rhs: Participant) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var admin: Bool?
    public var auditor: Bool?
    public var blocked: Bool?
    public var cellphoneNumber: String?
    public var contactFirstName: String?
    public var contactId: Int?
    public var contactName: String?
    public var contactLastName: String?
    public var coreUserId: Int?
    public var email: String?
    public var firstName: String?
    public var id: Int?
    public var image: String?
    public var keyId: String?
    public var lastName: String?
    public var myFriend: Bool?
    public var name: String?
    public var notSeenDuration: Int?
    public var online: Bool?
    public var receiveEnable: Bool?
    public var roles: [String]?
    public var sendEnable: Bool?
    public var username: String?
    public var chatProfileVO: Profile?

    public init(
        admin: Bool? = nil,
        auditor: Bool? = nil,
        blocked: Bool? = nil,
        cellphoneNumber: String? = nil,
        contactFirstName: String? = nil,
        contactId: Int? = nil,
        contactName: String? = nil,
        contactLastName: String? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        firstName: String? = nil,
        id: Int? = nil,
        image: String? = nil,
        keyId: String? = nil,
        lastName: String? = nil,
        myFriend: Bool? = nil,
        name: String? = nil,
        notSeenDuration: Int? = nil,
        online: Bool? = nil,
        receiveEnable: Bool? = nil,
        roles: [String]? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        chatProfileVO: Profile? = nil
    ) {
        self.admin = admin
        self.auditor = auditor
        self.blocked = blocked
        self.cellphoneNumber = cellphoneNumber
        self.contactFirstName = contactFirstName
        self.contactId = contactId
        self.contactName = contactName
        self.contactLastName = contactLastName
        self.coreUserId = coreUserId
        self.email = email
        self.firstName = firstName
        self.id = id
        self.image = image
        self.keyId = keyId
        self.lastName = lastName
        self.myFriend = myFriend
        self.name = name
        self.notSeenDuration = notSeenDuration
        self.online = online
        self.receiveEnable = receiveEnable
        self.roles = roles
        self.sendEnable = sendEnable
        self.username = username
        self.chatProfileVO = chatProfileVO
    }

    public init(theParticipant: Participant) {
        admin = theParticipant.admin
        auditor = theParticipant.auditor
        blocked = theParticipant.blocked
        cellphoneNumber = theParticipant.cellphoneNumber
        contactFirstName = theParticipant.contactFirstName
        contactId = theParticipant.contactId
        contactName = theParticipant.contactName
        contactLastName = theParticipant.contactLastName
        coreUserId = theParticipant.coreUserId
        email = theParticipant.email
        firstName = theParticipant.firstName
        id = theParticipant.id
        image = theParticipant.image
        keyId = theParticipant.keyId
        lastName = theParticipant.lastName
        myFriend = theParticipant.myFriend
        name = theParticipant.name
        notSeenDuration = theParticipant.notSeenDuration
        online = theParticipant.online
        receiveEnable = theParticipant.receiveEnable
        roles = theParticipant.roles
        sendEnable = theParticipant.sendEnable
        username = theParticipant.username
        chatProfileVO = theParticipant.chatProfileVO
    }

    private enum CodingKeys: String, CodingKey {
        case admin
        case auditor
        case blocked
        case cellphoneNumber
        case contactFirstName
        case contactId
        case contactName
        case contactLastName
        case coreUserId
        case email
        case firstName
        case id
        case image
        case keyId
        case lastName
        case myFriend
        case name
        case notSeenDuration
        case online
        case receiveEnable
        case sendEnable
        case username
        case chatProfileVO
        case roles
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        admin = try container.decodeIfPresent(Bool.self, forKey: .admin)
        auditor = try container.decodeIfPresent(Bool.self, forKey: .auditor)
        blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked)
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        contactFirstName = try container.decodeIfPresent(String.self, forKey: .contactFirstName)
        contactId = try container.decodeIfPresent(Int.self, forKey: .contactId)
        contactName = try container.decodeIfPresent(String.self, forKey: .contactName)
        contactLastName = try container.decodeIfPresent(String.self, forKey: .contactLastName)
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        keyId = try container.decodeIfPresent(String.self, forKey: .keyId)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        myFriend = try container.decodeIfPresent(Bool.self, forKey: .myFriend)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        notSeenDuration = try container.decodeIfPresent(Int.self, forKey: .notSeenDuration)
        online = try container.decodeIfPresent(Bool.self, forKey: .online)
        receiveEnable = try container.decodeIfPresent(Bool.self, forKey: .receiveEnable)
        sendEnable = try container.decodeIfPresent(Bool.self, forKey: .sendEnable)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        chatProfileVO = try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
        roles = try container.decodeIfPresent([String].self, forKey: .roles)
    }
}
