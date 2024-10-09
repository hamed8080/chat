//
// DeliverCallRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct DeliverCallRequest: Decodable {
    public let userId: Int
    public let callStatus: CallStatus
    public let mute: Bool
    public let video: Bool


    private enum CodingKeys: CodingKey {
        case userId
        case callStatus
        case mute
        case video
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(Int.self, forKey: .userId)
        self.callStatus = try container.decode(CallStatus.self, forKey: .callStatus)
        self.mute = try container.decode(Bool.self, forKey: .mute)
        self.video = try container.decode(Bool.self, forKey: .video)
    }
}
