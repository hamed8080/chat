//
// RTCSignalingState+.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

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
