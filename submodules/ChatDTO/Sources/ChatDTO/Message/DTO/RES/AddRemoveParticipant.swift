//
// AddRemoveParticipant.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AddRemoveParticipant: Decodable {
    public var participnats: [Participant]?
    public var requestType: Int?
    public var requestTime: UInt?

    public init(participnats: [Participant]? = nil, requestType: Int? = nil, requestTime: UInt? = nil) {
        self.participnats = participnats
        self.requestType = requestType
        self.requestTime = requestTime
    }

    private enum CodingKeys: String, CodingKey {
        case participnats = "participantVOS"
        case requestType
        case requestTime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        participnats = try container.decodeIfPresent([Participant].self, forKey: .participnats)
        requestType = try container.decodeIfPresent(Int.self, forKey: .requestType)
        requestTime = try container.decodeIfPresent(UInt.self, forKey: .requestTime)
    }
}
