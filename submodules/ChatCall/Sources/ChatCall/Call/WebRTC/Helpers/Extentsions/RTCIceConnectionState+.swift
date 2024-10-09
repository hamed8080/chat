//
// RTCIceConnectionState+.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC

extension RTCIceConnectionState {
    var stringValue: String {
        switch self {
        case .checking: return "checking"
        case .closed: return "closed"
        case .completed: return "completed"
        case .connected: return "connected"
        case .count: return "count"
        case .disconnected: return "disconnected"
        case .failed: return "failed"
        case .new: return "new"
        @unknown default:
            return "A unknown type found in RTCIceConnectionState.swift!"
        }
    }
}
