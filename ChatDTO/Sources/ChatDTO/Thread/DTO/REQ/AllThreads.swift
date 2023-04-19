//
// AllThreads.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class AllThreads: UniqueIdManagerRequest, ChatSendable {
    /// - summary: If it set to true the result only contains the ids of threads not other properties.
    private let summary: Bool = true
    public var chatMessageType: ChatMessageVOTypes = .getThreads
    public var content: String? { jsonString }

    /// Init the request.
    /// - Parameters:
    ///   - uniqueId: The optional uniqueId.
    override public init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case summary
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(summary, forKey: .summary)
    }
}
