//
// UpdateChatProfile.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class UpdateChatProfile: UniqueIdManagerRequest, ChatSendable {
    public let bio: String?
    public let metadata: String?
    var chatMessageType: ChatMessageVOTypes = .setProfile
    var content: String? { convertCodableToString() }

    public init(bio: String?, metadata: String? = nil, uniqueId: String? = nil) {
        self.bio = bio
        self.metadata = metadata
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case bio
        case metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
