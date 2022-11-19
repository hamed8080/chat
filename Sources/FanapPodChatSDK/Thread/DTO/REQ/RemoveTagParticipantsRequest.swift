//
// RemoveTagParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RemoveTagParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var tagId: Int
    public var tagParticipants: [TagParticipant]
    var subjectId: Int { tagId }
    var content: String? { tagParticipants.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .removeTagParticipants

    public init(tagId: Int, tagParticipants: [TagParticipant], uniqueId: String? = nil) {
        self.tagId = tagId
        self.tagParticipants = tagParticipants
        super.init(uniqueId: uniqueId)
    }
}
