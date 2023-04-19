//
// GetTagParticipantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class GetTagParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var id: Int
    public var subjectId: Int { id }
    public var chatMessageType: ChatMessageVOTypes = .getTagParticipants
    public var content: String?

    public init(id: Int, uniqueId: String? = nil) {
        self.id = id
        super.init(uniqueId: uniqueId)
    }
}
