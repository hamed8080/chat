//
// CallError.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
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
}
