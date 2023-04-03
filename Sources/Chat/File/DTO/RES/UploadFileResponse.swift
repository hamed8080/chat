//
// UploadFileResponse.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public final class UploadFileResponse: Decodable {
    let name: String?
    let hash: String?
    let parentHash: String?
    let created: Int64?
    let updated: Int64?
    let `extension`: String?
    let size: Int64?
    let type: String?
    let actualHeight: Int64?
    let actualWidth: Int64?

    let owner: FileOwner?
    let uploader: FileOwner?
}

public struct FileOwner: Decodable {
    public let username: String?
    public let name: String?
    public let ssoId: Int?
    public let avatar: String?
    public let roles: [String]
}
