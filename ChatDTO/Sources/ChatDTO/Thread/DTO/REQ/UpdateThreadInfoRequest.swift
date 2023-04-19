//
// UpdateThreadInfoRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class UpdateThreadInfoRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let description: String?
    public var metadata: String?
    public var threadImage: UploadImageRequest?
    public let threadId: Int
    public let title: String?
    public var subjectId: Int { threadId }
    public var chatMessageType: ChatMessageVOTypes = .updateThreadInfo
    public var content: String? { jsonString }

    public init(description: String? = nil,
                metadata: String? = nil,
                threadId: Int,
                threadImage: UploadImageRequest? = nil,
                title: String,
                uniqueId: String? = nil)
    {
        self.description = description
        self.metadata = metadata
        self.threadId = threadId
        self.threadImage = threadImage
        self.title = title
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case description
        case name
        case metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(title, forKey: .name)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
