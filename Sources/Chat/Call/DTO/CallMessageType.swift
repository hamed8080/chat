//
// CallMessageType.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum CallMessageType: String, Codable {
    case createSession = "CREATE_SESSION"
    case sessionNewCreated = "SESSION_NEW_CREATED"
    case sessionRefresh = "SESSION_REFRESH"
    case getKeyFrame = "GET_KEY_FRAME"
    case sendSdpOffer = "SEND_SDP_OFFER"
    case addIceCandidate = "ADD_ICE_CANDIDATE"
    case processSdpAnswer = "PROCESS_SDP_ANSWER"
    case processSdpUpdate = "PROCESS_SDP_UPDATE"
    case receiveSdpOffer = "RECIVE_SDP_OFFER"
    case close = "CLOSE"
    case stopAll = "STOPALL"
    case stop = "STOP"
    case freezed = "FREEZED"
    case receivingMedia = "RECEIVING_MEDIA"
    case recieveMetadata = "RECEIVEMETADATA"
    case sdpAnswerReceived = "SDP_ANSWER_RECEIVED"
    case error = "ERROR"
    case unkown

    // prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else {
            self = .unkown
            return
        }
        self = CallMessageType(rawValue: value) ?? .unkown
    }
}
