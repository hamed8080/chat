//
// ChangeThreadTypeRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class ChangeThreadTypeRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let uniqueName: String?
    public var threadId: Int
    public var type: ThreadTypes
    var subjectId: Int { threadId }
    var chatMessageType: ChatMessageVOTypes = .changeThreadType
    var content: String? { convertCodableToString() }

    public init(threadId: Int, type: ThreadTypes, uniqueName: String? = nil, uniqueId: String? = nil) {
        self.type = type
        self.threadId = threadId
        self.uniqueName = uniqueName
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case uniqueName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(type, forKey: .type)
        try? container.encodeIfPresent(uniqueName, forKey: .uniqueName)
    }
}
