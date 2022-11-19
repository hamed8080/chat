//
// EditTagRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class EditTagRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var name: String
    public var id: Int
    var subjectId: Int { id }
    var chatMessageType: ChatMessageVOTypes = .editTag
    var content: String? { convertCodableToString() }

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
