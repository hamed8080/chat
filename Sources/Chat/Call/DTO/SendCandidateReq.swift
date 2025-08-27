//
// SendCandidateReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendCandidateReq: Codable, AsyncSnedable {
    let id: CallMessageType = .addIceCandidate
    let token: String
    let topic: String
    let candidate: IceCandidate
    var asyncMessageType: AsyncMessageTypes? = .message
    var content: String? { jsonString }
    var peerName: String?

    public init(peerName: String, token: String, topic: String, candidate: IceCandidate) {
        self.peerName = peerName
        self.token = token
        self.topic = topic
        self.candidate = candidate
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case token
        case topic
        case candidate = "candidateDto"
    }
}
