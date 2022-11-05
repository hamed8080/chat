//
// SendSignalMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class SendSignalMessageRequest: BaseRequest {
    public let signalType: SignalMessageType
    public let threadId: Int

    public init(signalType: SignalMessageType, threadId: Int, uniqueId: String? = nil) {
        self.signalType = signalType
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(signalType.rawValue)", forKey: .type)
    }
}
