//
// CreateTagRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class CreateTagRequest: UniqueIdManagerRequest, ChatSendable {
    public var name: String
    public var content: String? { jsonString }
    public var chatMessageType: ChatMessageVOTypes = .createTag

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
