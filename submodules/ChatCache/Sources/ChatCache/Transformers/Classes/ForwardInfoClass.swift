//
// ForwardInfoClass.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public class ForwardInfoClass: NSObject, Codable {
    public var conversation: ForwardInfoConversation?
    public var participant: Participant?

    private enum CodingKeys: String, CodingKey {
        case conversation
        case participant
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        conversation = try container.decodeIfPresent(ForwardInfoConversation.self, forKey: .conversation)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
    }

    public init(conversation: ForwardInfoConversation?, participant: Participant?) {
        self.conversation = conversation
        self.participant = participant
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(conversation, forKey: .conversation)
    }
}

public extension ForwardInfo {
    var toClass: ForwardInfoClass {
        let forwardInfo = ForwardInfoClass(conversation: conversation, participant: participant)
        return forwardInfo
    }
}

public extension ForwardInfoClass {
    var toStruct: ForwardInfo {
        let forwardInfo = ForwardInfo(conversation: conversation, participant: participant)
        return forwardInfo
    }
}
