//
// User.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class User: Codable {
    public var cellphoneNumber: String?
    public var contactSynced: Bool = false
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

    public init(
        cellphoneNumber: String? = nil,
        contactSynced: Bool? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        id: Int? = nil,
        image: String? = nil,
        lastSeen: Int? = nil,
        name: String? = nil,
        receiveEnable: Bool? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        ssoId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        chatProfileVO: Profile? = nil
    ) {
        self.cellphoneNumber = cellphoneNumber
        self.contactSynced = contactSynced ?? false
        self.coreUserId = coreUserId
        self.email = email
        self.id = id
        self.image = image
        self.lastSeen = lastSeen
        self.name = name
        self.receiveEnable = receiveEnable
        self.sendEnable = sendEnable
        self.username = username
        self.ssoId = ssoId
        self.lastName = lastName
        self.firstName = firstName
        self.chatProfileVO = chatProfileVO
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case contactSynced
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
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        contactSynced = try container.decodeIfPresent(Bool.self, forKey: .contactSynced) ?? false
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        lastSeen = try container.decodeIfPresent(Int.self, forKey: .lastSeen)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        receiveEnable = try container.decodeIfPresent(Bool.self, forKey: .receiveEnable)
        sendEnable = try container.decodeIfPresent(Bool.self, forKey: .sendEnable)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        chatProfileVO = try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
        ssoId = try container.decodeIfPresent(String.self, forKey: .ssoId)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    }
}
