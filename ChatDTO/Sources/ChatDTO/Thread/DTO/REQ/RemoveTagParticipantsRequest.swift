//
// RemoveTagParticipantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore
import ChatModels

public final class RemoveTagParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var tagId: Int
    public var tagParticipants: [TagParticipant]
    public var subjectId: Int { tagId }
    public var content: String? { tagParticipants.jsonString }
    public var chatMessageType: ChatMessageVOTypes = .removeTagParticipants

    public init(tagId: Int, tagParticipants: [TagParticipant], uniqueId: String? = nil) {
        self.tagId = tagId
        self.tagParticipants = tagParticipants
        super.init(uniqueId: uniqueId)
    }
}
