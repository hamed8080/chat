//
// RTCSignalingState.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import WebRTC
extension RTCSignalingState {
    var stringValue: String {
        switch self {
        case .closed: return "closed"
        case .haveLocalOffer: return "haveLocalOffer"
        case .haveLocalPrAnswer: return "haveLocalPrAnswer"
        case .haveRemoteOffer: return "haveRemoteOffer"
        case .haveRemotePrAnswer: return "haveRemotePrAnswer"
        case .stable: return "stable"
        @unknown default:
            return "unknownState"
        }
    }
}
