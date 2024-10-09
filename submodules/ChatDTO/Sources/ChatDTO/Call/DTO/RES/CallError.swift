//
// CallError.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct CallError: Codable {
    public var code: CallClientErrorType?
    public var message: String?
    public var participant: Participant

    public init(code: CallClientErrorType? = nil, message: String? = nil, participant: Participant) {
        self.code = code
        self.message = message
        self.participant = participant
    }

    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case participant
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.code, forKey: .code)
        try container.encodeIfPresent(self.message, forKey: .message)
        try container.encode(self.participant, forKey: .participant)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(CallClientErrorType.self, forKey: .code)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.participant = try container.decode(Participant.self, forKey: .participant)
    }
}
