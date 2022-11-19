//
// GetTagParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class GetTagParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var id: Int
    var subjectId: Int { id }
    var chatMessageType: ChatMessageVOTypes = .getTagParticipants
    var content: String?

    public init(id: Int, uniqueId: String? = nil) {
        self.id = id
        super.init(uniqueId: uniqueId)
    }
}
