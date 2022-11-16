//
// FileRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class FileRequest: BaseRequest, Encodable {
    public let hashCode: String
    public let checkUserGroupAccess: Bool
    public var forceToDownloadFromServer: Bool

    public init(hashCode: String, checkUserGroupAccess: Bool = true, forceToDownloadFromServer: Bool = false, uniqueId: String? = nil) {
        self.hashCode = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.checkUserGroupAccess = checkUserGroupAccess
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case uniqueId
        case checkUserGroupAccess
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(uniqueId, forKey: .uniqueId)
        try? container.encode(checkUserGroupAccess, forKey: .checkUserGroupAccess)
    }
}
