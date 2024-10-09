//
// CancelGroupCall.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct CancelGroupCall: Codable {
    public let userId: Int
    public let mute: Bool
    public let joinTime: Int?
    public let leaveTime: Int?
    public let callStatus: CallStatus?
    public let participant: Participant?
    public let video: Bool
    public var callId: Int?

    private enum CodingKeys: String, CodingKey {
        case userId
        case mute
        case joinTime
        case leaveTime
        case callStatus
        case participant = "participantVO"
        case video
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.mute, forKey: .mute)
        try container.encodeIfPresent(self.joinTime, forKey: .joinTime)
        try container.encodeIfPresent(self.leaveTime, forKey: .leaveTime)
        try container.encodeIfPresent(self.callStatus, forKey: .callStatus)
        try container.encodeIfPresent(self.participant, forKey: .participant)
        try container.encode(self.video, forKey: .video)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.mute = try container.decode(Bool.self, forKey: .mute)
        self.joinTime = try container.decodeIfPresent(Int.self, forKey: .joinTime)
        self.leaveTime = try container.decodeIfPresent(Int.self, forKey: .leaveTime)
        self.callStatus = try container.decodeIfPresent(CallStatus.self, forKey: .callStatus)
        self.participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        self.video = try container.decode(Bool.self, forKey: .video)
    }
}
