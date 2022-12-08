//
// SignalingMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
import WebRTC

enum SdpType: String, Codable {
    case offer
    case prAnswer
    case answer
    case rollback

    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:
            return .offer
        case .answer:
            return .answer
        case .prAnswer:
            return .prAnswer
        case .rollback:
            return .rollback
        }
    }

    static func toSdpType(rtcSdpType: RTCSdpType) -> SdpType {
        switch rtcSdpType {
        case .offer:
            return .offer
        case .answer:
            return .answer
        case .prAnswer:
            return .prAnswer
        case .rollback:
            return .rollback
        @unknown default:
            return .rollback
        }
    }
}

struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType

    init(from rtcSessionDescription: RTCSessionDescription) {
        sdp = rtcSessionDescription.sdp

        switch rtcSessionDescription.type {
        case .offer: type = .offer
        case .prAnswer: type = .prAnswer
        case .answer: type = .answer
        case .rollback: type = .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }

    var rtcSessionDescription: RTCSessionDescription {
        RTCSessionDescription(type: type.rtcSdpType, sdp: sdp)
    }
}

public struct IceCandidate: Codable {
    let candidate: String
    let sdpMLineIndex: Int32
    let sdpMid: String?

    init(from rtcIce: RTCIceCandidate) {
        candidate = rtcIce.sdp
        sdpMLineIndex = rtcIce.sdpMLineIndex
        sdpMid = rtcIce.sdpMid
    }

    var replaceSpaceSdpIceCandidate: IceCandidate {
        let newICEReplaceSpace = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
        let newIceCandidate = IceCandidate(from: newICEReplaceSpace)
        return newIceCandidate
    }

    var rtcIceCandidate: RTCIceCandidate {
        RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}

struct SignalingMessage: Codable {
    let type: String?
    let uniqueId: String?
    let sdp: SessionDescription?
    let ice: IceCandidate?

    internal init(sdp: SessionDescription) {
        self.sdp = sdp
        ice = nil
        uniqueId = nil
        type = nil
    }

    internal init(ice: IceCandidate?) {
        sdp = nil
        self.ice = ice
        uniqueId = nil
        type = nil
    }

    private enum CodingKeys: String, CodingKey {
        case type = "id"
        case sdp
        case ice
        case uniqueId
    }
}
