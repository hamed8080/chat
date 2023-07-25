//
// UploadFileResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public class UploadFileResponse: Decodable {
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
}

public struct FileOwner: Decodable {
    public let username: String?
    public let name: String?
    public let ssoId: Int?
    public let avatar: String?
    public let roles: [String]
}
