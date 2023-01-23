//
// AddCallParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class AddCallParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    let callId: Int
    var contactIds: [Int]?
    var userNames: [Invitee]?
    var coreuserIds: [Invitee]?
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .addCallParticipant
    var subjectId: Int { callId }

    public init(callId: Int, uniqueId: String? = nil) {
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int, contactIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        self.contactIds = contactIds

        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int, userNames: [String], uniqueId: String? = nil) {
        self.callId = callId
        var invitess: [Invitee] = []
        userNames.forEach { userame in
            invitess.append(Invitee(id: userame, idType: .username))
        }
        self.userNames = invitess

        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int, coreUserIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        var invitess: [Invitee] = []
        coreUserIds.forEach { coreuserId in
            invitess.append(Invitee(id: "\(coreuserId)", idType: .coreUserId))
        }
        coreuserIds = invitess

        super.init(uniqueId: uniqueId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let contactids = contactIds, contactids.count > 0 {
            try? container.encode(contactids)
        }

        if let coreUserIds = coreuserIds {
            try? container.encode(coreUserIds)
        }

        if let userNames = userNames {
            try? container.encode(userNames)
        }
    }
}
