//
// SignalingState.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public enum SignalingState: Codable, Sendable {
    case stable
    case haveLocalOffer
    case haveLocalPrAnswer
    case haveRemoteOffer
    case haveRemotePrAnswer
    // Not an case state, represents the total number of states.
    case closed
    case unknown

    public init(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .stable
        case 1:
            self = .haveLocalOffer
        case 2:
            self = .haveLocalPrAnswer
        case 3:
            self = .haveRemoteOffer
        case 4:
            self = .haveRemotePrAnswer
        case 5:
            self = .closed
        default:
            self = .unknown
        }
    }
}

public enum IceConnectionState: Codable, Sendable {
    case new
    case checking
    case connected
    case completed
    case failed
    case disconnected
    case closed
    case count
    case unknown

    public init(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .new
        case 1:
            self = .checking
        case 2:
            self = .connected
        case 3:
            self = .completed
        case 4:
            self = .failed
        case 5:
            self = .disconnected
        case 6:
            self = .closed
        case 7:
            self = .count
        default:
            self = .unknown
        }
    }
}

public enum PeerConnectionState: Codable, Sendable {
    case new
    case connecting
    case connected
    case disconnected
    case failed
    case closed
    case unknown

    public init(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .new
        case 1:
            self = .connecting
        case 2:
            self = .connected
        case 3:
            self = .disconnected
        case 4:
            self = .failed
        case 5:
            self = .closed
        default:
            self = .unknown
        }
    }
}

public enum IceGatheringState: Codable, Sendable {
    case new
    case gathering
    case complete
    case unknown

    public init(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .new
        case 1:
            self = .gathering
        case 2:
            self = .complete
        default:
            self = .unknown
        }
    }
}
