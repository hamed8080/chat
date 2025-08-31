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
    
    // MARK: Ice candidate
    case addIceCandidate = "ADD_ICE_CANDIDATE"
    case sendIceCandidate = "SEND_ADD_ICE_CANDIDATE"
    case receiveAddIceCandidate = "RECIVE_ADD_ICE_CANDIDATE"
    
    // MARK: SDP
    case sendSdpOffer = "SEND_SDP_OFFER"
    case processSdpAnswer = "PROCESS_SDP_ANSWER"
    case processSdpUpdate = "PROCESS_SDP_UPDATE"
    case receiveSdpOffer = "RECIVE_SDP_OFFER"
    case prcessSdpNegotiate = "PROCESS_SDP_NEGOTIATE"
    case processLatestSdpOffer = "PROCESS_LATEST_SDP_OFFER"
    case sdpAnswerReceived = "SDP_ANSWER_RECEIVED"
    
    // MARK: Metadata
    case receivingMedia = "RECEIVING_MEDIA"
    case recieveMetadata = "RECEIVEMETADATA"
    case sendMetadata = "SENDMETADATA"
    case requestReceivingMedia = "REQUEST_RECEIVING_MEDIA"
    
    // MARK: Subscription / Publisher
    case joinAdditionComplete = "JOIN_AADDITIONN_COMPLETE"
    case joinDeletionComplete = "JOIN_DELETION_COMPLETE"
    case subscriptionFailed = "SUB_FAILED"
    case updateFailed = "UPDATE_FAILED"
    case releaseResources = "RELEASE_RESOURCES"
    case subscribe = "SUBSCRIBE"
    case update = "UPDATE"
    
    case close = "CLOSE"
    case slowLink = "SLOW_LINK"
    case stopAll = "STOPALL"
    case stop = "STOP"
    case freezed = "FREEZED"
    
    case exitClient = "EXIT_CLIENT"
    case sendComplete = "SEND_COMPLETE"
    case unpublished = "UNPUBLISHED"
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
