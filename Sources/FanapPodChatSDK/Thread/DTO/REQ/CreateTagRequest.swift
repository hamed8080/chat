//
// CreateTagRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class CreateTagRequest: UniqueIdManagerRequest, ChatSendable {
    public var name: String
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .createTag

    public init(tagName: String, uniqueId: String? = nil) {
        name = tagName
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
    }
}
