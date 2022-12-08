//
// CallParticipant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct CallParticipant: Codable, Equatable {
    static public func == (lhs: CallParticipant, rhs: CallParticipant) -> Bool {
        return lhs.userId == rhs.userId
    }
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
        self.joinTime = try container.decodeIfPresent(Int.self, forKey: .joinTime)
        self.leaveTime = try container.decodeIfPresent(Int.self, forKey: .leaveTime)
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        self.sendTopic = try container.decode(String.self, forKey: .sendTopic)
        self.receiveTopic = try container.decodeIfPresent(String.self, forKey: .receiveTopic)
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active) ?? true
        self.callStatus = try container.decodeIfPresent(CallStatus.self, forKey: .callStatus)
        self.participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        self.mute = try container.decode(Bool.self, forKey: .mute)
        self.video = try container.decodeIfPresent(Bool.self, forKey: .video)
    }

    public var topics: (topicVideo: String, topicAudio: String) {
        return ("Vi-\(sendTopic)", "Vo-\(sendTopic)")
    }
}

extension CallParticipant {
    public mutating func update(_ newCallParticipant: CallParticipant) {
        self.joinTime = newCallParticipant.joinTime
        self.leaveTime = newCallParticipant.leaveTime
        self.callStatus = newCallParticipant.callStatus
        self.participant = newCallParticipant.participant
    }
}
