//
// RemoveParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class RemoveParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let participantIds: [Int]
    public let threadId: Int
    var content: String? { participantIds.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .removeParticipant
    var subjectId: Int { threadId }

    public init(participantId: Int, threadId: Int, uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        participantIds = [participantId]
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }

    public init(participantIds: [Int], threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        self.participantIds = participantIds
        super.init(uniqueId: uniqueId)
    }
}
