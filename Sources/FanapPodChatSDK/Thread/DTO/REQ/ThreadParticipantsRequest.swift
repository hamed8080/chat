//
// ThreadParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class ThreadParticipantsRequest: BaseRequest, ChatSnedable, SubjectProtocol {
    public let count: Int
    public let offset: Int
    public let threadId: Int

    var content: String? { convertCodableToString() }
    var subjectId: Int? { threadId }
    var chatMessageType: ChatMessageVOTypes = .threadParticipants

    /// If it set to true the request only contains the list of admins of a thread.
    public var admin: Bool = false

    public init(threadId: Int, offset: Int = 0, count: Int = 50, admin: Bool = false, uniqueId: String? = nil) {
        self.count = count
        self.offset = offset
        self.threadId = threadId
        self.admin = admin
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case admin
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(admin, forKey: .admin)
    }
}
