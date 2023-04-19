//
// AddTagParticipantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class AddTagParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var tagId: Int
    public var threadIds: [Int]
    public var subjectId: Int { tagId }
    public var chatMessageType: ChatMessageVOTypes = .addTagParticipants
    public var content: String? { threadIds.jsonString }

    public init(tagId: Int, threadIds: [Int], uniqueId: String? = nil) {
        self.threadIds = threadIds
        self.tagId = tagId
        super.init(uniqueId: uniqueId)
    }
}
