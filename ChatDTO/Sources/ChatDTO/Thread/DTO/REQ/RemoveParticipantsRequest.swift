//
// RemoveParticipantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class RemoveParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let participantIds: [Int]
    public let threadId: Int
    public var content: String? { participantIds.jsonString }
    public var chatMessageType: ChatMessageVOTypes = .removeParticipant
    public var subjectId: Int { threadId }

    public init(participantId: Int, threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        participantIds = [participantId]
        super.init(uniqueId: uniqueId)
    }

    public init(participantIds: [Int], threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        self.participantIds = participantIds
        super.init(uniqueId: uniqueId)
    }
}
