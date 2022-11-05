//
// DeliverCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
struct DeliverCallRequest: Decodable {
    public let userId: Int
    public let callStatus: CallStatus
    public let mute: Bool
    public let video: Bool
}
