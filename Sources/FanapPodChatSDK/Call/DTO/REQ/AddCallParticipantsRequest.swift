//
// AddCallParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class AddCallParticipantsRequest: BaseRequest {
    let callId: Int?
    var contactIds: [Int]?
    var userNames: [Invitee]?
    var coreuserIds: [Invitee]?

    public init(callId: Int? = nil, uniqueId: String? = nil) {
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int? = nil, contactIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        self.contactIds = contactIds

        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int? = nil, userNames: [String], uniqueId: String? = nil) {
        self.callId = callId
        var invitess: [Invitee] = []
        userNames.forEach { userame in
            invitess.append(Invitee(id: userame, idType: .username))
        }
        self.userNames = invitess

        super.init(uniqueId: uniqueId)
    }

    public init(callId: Int? = nil, coreUserIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        var invitess: [Invitee] = []
        coreUserIds.forEach { coreuserId in
            invitess.append(Invitee(id: "\(coreuserId)", idType: .coreUserId))
        }
        coreuserIds = invitess

        super.init(uniqueId: uniqueId)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let contactids = contactIds, contactids.count > 0 {
            try? container.encode(contactids)
        }

        if let coreUserIds = contactIds {
            try? container.encode(coreUserIds)
        }

        if let userNames = userNames {
            try? container.encode(userNames)
        }
    }
}
