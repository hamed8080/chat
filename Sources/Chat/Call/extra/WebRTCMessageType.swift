//
// WebRTCMessageType.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

enum WebRTCMessageType: String, Decodable {
    case createSession = "CREATE_SESSION"
    case sessionNewCreated = "SESSION_NEW_CREATED"
    case sessionRefresh = "SESSION_REFRESH"
    case getKeyFrame = "GET_KEY_FRAME"
    case addIceCandidate = "ADD_ICE_CANDIDATE"
    case processSdpAnswer = "PROCESS_SDP_ANSWER"
    case close = "CLOSE"
    case stopAll = "STOPALL"
    case stop = "STOP"
    case receivingMedia = "RECEIVING_MEDIA"
    case unkown

    // prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else {
            self = .unkown
            return
        }
        self = WebRTCMessageType(rawValue: value) ?? .unkown
    }
}
