//
// EditTagRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class EditTagRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var name: String
    public var id: Int
    public var subjectId: Int { id }
    public var chatMessageType: ChatMessageVOTypes = .editTag
    public var content: String? { jsonString }

    public init(id: Int, tagName: String, uniqueId: String? = nil) {
        self.id = id
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
