//
// BlockedContactResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct BlockedContactResponse: Decodable {
    public var blockId: Int?
    public var firstName: String?
    public var lastName: String?
    public var nickName: String?
    public var profileImage: String?
    public var coreUserId: Int?
    public var contact: Contact?

    private enum CodingKeys: String, CodingKey {
        case blockId = "id"
        case firstName
        case lastName
        case nickName
        case profileImage
        case coreUserId
        case contact = "contactVO"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blockId = try container.decodeIfPresent(Int.self, forKey: .blockId)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        nickName = try container.decodeIfPresent(String.self, forKey: .nickName)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId)
        contact = try container.decodeIfPresent(Contact.self, forKey: .contact)
    }
}
