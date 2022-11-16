//
// SendCandidateReq.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  SendCandidateReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import FanapPodAsyncSDK

struct SendCandidateReq: Codable, AsyncSnedable {
    var id: String = "ADD_ICE_CANDIDATE"
    var token: String
    var topic: String
    var candidate: IceCandidate
    var asyncMessageType: AsyncMessageTypes? = .message
    var content: String? { convertCodableToString() }
    var peerName: String?

    public init(peerName: String, id: String = "ADD_ICE_CANDIDATE", token: String, topic: String, candidate: IceCandidate) {
        self.peerName = peerName
        self.id = id
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
