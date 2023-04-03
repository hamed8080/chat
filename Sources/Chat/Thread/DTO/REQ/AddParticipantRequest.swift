//
// AddParticipantRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

public final class AddParticipantRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var id: String?
    public var idType: InviteeTypes?
    public var threadId: Int
    public var contactIds: [Int]?
    var subjectId: Int { threadId }
    var chatMessageType: ChatMessageVOTypes = .addParticipant
    var content: String? { jsonString }

    public init(userName: String, threadId: Int, uniqueId: String? = nil) {
        idType = .username
        id = userName
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    public init(coreUserId: Int, threadId: Int, uniqueId: String? = nil) {
        idType = .coreUserId
        id = "\(coreUserId)"
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    public init(contactIds: [Int], threadId: Int, uniqueId: String? = nil) {
        self.contactIds = contactIds
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case idType
    }

    public func encode(to encoder: Encoder) throws {
        if contactIds == nil {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try? container.encode(id, forKey: .id)
            try? container.encode(idType, forKey: .idType)
        } else if let contactIds = contactIds {
            var container = encoder.unkeyedContainer()
            try? container.encode(contentsOf: contactIds)
        }
    }
}
