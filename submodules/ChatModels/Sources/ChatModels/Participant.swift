//
// Participant.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Participant: Codable, Hashable, Identifiable, Sendable {
    public var admin: Bool?
    /// It means that the user is an assistant or not.
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
    public var ssoId: String?
    public var image: String?
    public var keyId: String?
    public var lastName: String?
    public var myFriend: Bool?
    public var name: String?
    public var notSeenDuration: Int?
    public var online: Bool?
    public var receiveEnable: Bool?
    public var roles: [Roles]?
    public var sendEnable: Bool?
    public var username: String?
    public var chatProfileVO: Profile?
    public var conversation: ParticipantConversation?
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
        ssoId: String? = nil,
        image: String? = nil,
        keyId: String? = nil,
        lastName: String? = nil,
        myFriend: Bool? = nil,
        name: String? = nil,
        notSeenDuration: Int? = nil,
        online: Bool? = nil,
        receiveEnable: Bool? = nil,
        roles: [Roles]? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        chatProfileVO: Profile? = nil,
        conversation: ParticipantConversation? = nil
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
        self.ssoId = ssoId
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
        self.conversation = conversation
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
        case ssoId
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
        case conversation
    }

    public init(from decoder: Decoder) throws {
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
        ssoId = try container.decodeIfPresent(String.self, forKey: .ssoId)
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
        roles = try container.decodeIfPresent([Roles].self, forKey: .roles)
        conversation = try container.decodeIfPresent(ParticipantConversation.self, forKey: .conversation)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(admin, forKey: .admin)
        try? container.encodeIfPresent(auditor, forKey: .auditor)
        try? container.encodeIfPresent(blocked, forKey: .blocked)
        try? container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(contactFirstName, forKey: .contactFirstName)
        try? container.encodeIfPresent(contactId, forKey: .contactId)
        try? container.encodeIfPresent(contactName, forKey: .contactName)
        try? container.encodeIfPresent(contactLastName, forKey: .contactLastName)
        try? container.encodeIfPresent(coreUserId, forKey: .coreUserId)
        try? container.encodeIfPresent(email, forKey: .email)
        try? container.encodeIfPresent(firstName, forKey: .firstName)
        try? container.encodeIfPresent(id, forKey: .id)
        try? container.encodeIfPresent(ssoId, forKey: .ssoId)
        try? container.encodeIfPresent(image, forKey: .image)
        try? container.encodeIfPresent(keyId, forKey: .keyId)
        try? container.encodeIfPresent(lastName, forKey: .lastName)
        try? container.encodeIfPresent(myFriend, forKey: .myFriend)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(notSeenDuration, forKey: .notSeenDuration)
        try? container.encodeIfPresent(online, forKey: .online)
        try? container.encodeIfPresent(receiveEnable, forKey: .receiveEnable)
        try? container.encodeIfPresent(sendEnable, forKey: .sendEnable)
        try? container.encodeIfPresent(username, forKey: .username)
        try? container.encodeIfPresent(chatProfileVO, forKey: .chatProfileVO)
        try? container.encodeIfPresent(roles, forKey: .roles)
        try? container.encodeIfPresent(conversation, forKey: .conversation)
    }
}

public extension Conversation {
    var toParticipantConversation: ParticipantConversation {
        let conPart = ParticipantConversation(
            description : description,
            group : group,
            id : id,
            image : image,
            metadata : metadata,
            participantCount : participantCount,
            title : title,
            type : type,
            uniqueName : uniqueName,
            userGroupHash : userGroupHash)
        return conPart
    }
}
