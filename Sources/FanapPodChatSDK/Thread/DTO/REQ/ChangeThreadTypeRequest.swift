//
// ChangeThreadTypeRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class ChangeThreadTypeRequest: BaseRequest {
    public let uniqueName: String?
    public var threadId: Int
    public var type: ThreadTypes

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

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(type, forKey: .type)
        try? container.encodeIfPresent(uniqueName, forKey: .uniqueName)
    }
}
