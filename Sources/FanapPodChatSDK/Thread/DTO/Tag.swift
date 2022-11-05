//
// Tag.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct Tag: Codable {
    public var id: Int
    public var name: String
    public var owner: Participant
    public var active: Bool
    public var tagParticipants: [TagParticipant]?

    public init(id: Int, name: String, owner: Participant, active: Bool, tagParticipants: [TagParticipant]? = nil) {
        self.id = id
        self.name = name
        self.owner = owner
        self.active = active
        self.tagParticipants = tagParticipants
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case active
        case tagParticipants = "tagParticipantVOList"
    }
}

public struct TagEventModel {
    let tag: Tag?
    let tagParticipants: [TagParticipant]?
    let type: TagEventType

    public init(tag: Tag? = nil, tagParticipants: [TagParticipant]? = nil, type: TagEventType) {
        self.tag = tag
        self.tagParticipants = tagParticipants
        self.type = type
    }
}

public enum TagEventType {
    case createTag
    case deleteTag
    case editTag
    case addTagParticipant
    case removeTagParticipant
}
