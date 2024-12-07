//
// CallParticipant.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct CallParticipant: Codable, Equatable, Sendable {
    public var joinTime: Int?
    public var leaveTime: Int?
    public var userId: Int?
    public var sendTopic: String
    public var receiveTopic: String?
    public var active: Bool
    public var callStatus: CallStatus?
    public var participant: Participant?
    public var mute: Bool
    public var video: Bool?

    public init(
        sendTopic: String,
        receiveTopic: String? = nil,
        joinTime: Int? = nil,
        leaveTime: Int? = nil,
        userId: Int? = nil,
        active: Bool = true,
        callStatus: CallStatus? = nil,
        mute: Bool = false,
        video: Bool? = nil,
        participant: Participant? = nil
    ) {
        self.joinTime = joinTime
        self.leaveTime = leaveTime
        self.userId = userId
        self.sendTopic = sendTopic
        self.receiveTopic = receiveTopic
        self.active = active
        self.callStatus = callStatus
        self.participant = participant
        self.mute = mute
        self.video = video
    }

    private enum CodingKeys: String, CodingKey {
        case joinTime
        case leaveTime
        case userId
        case sendTopic
        case receiveTopic
        case active
        case callStatus
        case participant = "participantVO"
        case mute
        case video
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        joinTime = try container.decodeIfPresent(Int.self, forKey: .joinTime)
        leaveTime = try container.decodeIfPresent(Int.self, forKey: .leaveTime)
        userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        sendTopic = try container.decode(String.self, forKey: .sendTopic)
        receiveTopic = try container.decodeIfPresent(String.self, forKey: .receiveTopic)
        active = try container.decodeIfPresent(Bool.self, forKey: .active) ?? true
        callStatus = try container.decodeIfPresent(CallStatus.self, forKey: .callStatus)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        mute = try container.decode(Bool.self, forKey: .mute)
        video = try container.decodeIfPresent(Bool.self, forKey: .video)
    }

    public var topics: (topicVideo: String, topicAudio: String) {
        return ("Vi-\(sendTopic)", "Vo-\(sendTopic)")
    }
}

public extension CallParticipant {
    mutating func update(_ newCallParticipant: CallParticipant) {
        joinTime = newCallParticipant.joinTime
        leaveTime = newCallParticipant.leaveTime
        callStatus = newCallParticipant.callStatus
        participant = newCallParticipant.participant
    }
}
