//
// CancelGroupCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct CancelGroupCall: Codable {

    public let userId: Int
    public let mute: Bool
    public let joinTime: Int?
    public let leaveTime: Int?
    public let callStatus: CallStatus?
    public let participant: Participant?
    public let video: Bool
    public var callId: Int?

    enum CodingKeys: String, CodingKey {
        case userId
        case mute
        case joinTime
        case leaveTime
        case callStatus
        case participant = "participantVO"
        case video
    }
}
