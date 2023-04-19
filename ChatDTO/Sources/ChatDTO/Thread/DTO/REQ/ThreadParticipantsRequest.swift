//
// ThreadParticipantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class ThreadParticipantsRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var count: Int
    public var offset: Int
    public var threadId: Int
    public var name: String?
    public var username: String?
    public var cellphoneNumber: String?
    /// If it set to true the request only contains the list of admins of a thread.
    public var admin: Bool = false

    public var content: String? { jsonString }
    public var subjectId: Int { threadId }
    public var chatMessageType: ChatMessageVOTypes = .threadParticipants

    public init(threadId: Int,
                offset: Int = 0,
                count: Int = 25,
                name: String? = nil,
                admin: Bool = false,
                cellphoneNumber: String? = nil,
                username: String? = nil,
                uniqueId: String? = nil)
    {
        self.count = count
        self.offset = offset
        self.threadId = threadId
        self.admin = admin
        self.username = username
        self.cellphoneNumber = cellphoneNumber
        self.name = name
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case admin
        case name
        case cellphoneNumber
        case username
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(admin, forKey: .admin)
        try? container.encodeIfPresent(name, forKey: .name)
        try? container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try? container.encodeIfPresent(username, forKey: .username)
    }
}
