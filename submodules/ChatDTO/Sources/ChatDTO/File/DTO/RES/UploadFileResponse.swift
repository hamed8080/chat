//
// UploadFileResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UploadFileResponse: Decodable, Sendable {
    public let name: String?
    public let hash: String?
    public let parentHash: String?
    public let created: Int64?
    public let updated: Int64?
    public let `extension`: String?
    public let size: Int64?
    public let type: String?
    public let actualHeight: Int64?
    public let actualWidth: Int64?

    public let owner: FileOwner?
    public let uploader: FileOwner?

    private enum CodingKeys: CodingKey {
        case name
        case hash
        case parentHash
        case created
        case updated
        case `extension`
        case size
        case type
        case actualHeight
        case actualWidth
        case owner
        case uploader
    }

    public init(name: String? = nil, hash: String? = nil, parentHash: String? = nil, created: Int64? = nil, updated: Int64? = nil, `extension`: String? = nil, size: Int64? = nil, type: String? = nil, actualHeight: Int64? = nil, actualWidth: Int64? = nil, owner: FileOwner? = nil, uploader: FileOwner? = nil) {
        self.name = name
        self.hash = hash
        self.parentHash = parentHash
        self.created = created
        self.updated = updated
        self.`extension` = `extension`
        self.size = size
        self.type = type
        self.actualHeight = actualHeight
        self.actualWidth = actualWidth
        self.owner = owner
        self.uploader = uploader
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.hash = try container.decodeIfPresent(String.self, forKey: .hash)
        self.parentHash = try container.decodeIfPresent(String.self, forKey: .parentHash)
        self.created = try container.decodeIfPresent(Int64.self, forKey: .created)
        self.updated = try container.decodeIfPresent(Int64.self, forKey: .updated)
        self.extension = try container.decodeIfPresent(String.self, forKey: .extension)
        self.size = try container.decodeIfPresent(Int64.self, forKey: .size)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.actualHeight = try container.decodeIfPresent(Int64.self, forKey: .actualHeight)
        self.actualWidth = try container.decodeIfPresent(Int64.self, forKey: .actualWidth)
        self.owner = try container.decodeIfPresent(FileOwner.self, forKey: .owner)
        self.uploader = try container.decodeIfPresent(FileOwner.self, forKey: .uploader)
    }
}

public struct FileOwner: Decodable, Sendable {
    public let username: String?
    public let name: String?
    public let ssoId: Int?
    public let avatar: String?
    public let roles: [String]

    private enum CodingKeys: CodingKey {
        case username
        case name
        case ssoId
        case avatar
        case roles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.ssoId = try container.decodeIfPresent(Int.self, forKey: .ssoId)
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        self.roles = try container.decode([String].self, forKey: .roles)
    }

    public init(username: String? = nil, name: String? = nil, ssoId: Int? = nil, avatar: String? = nil, roles: [String]) {
        self.username = username
        self.name = name
        self.ssoId = ssoId
        self.avatar = avatar
        self.roles = roles
    }
}
