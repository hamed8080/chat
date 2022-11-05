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

struct SendCandidateReq: Codable {
    var id: String = "ADD_ICE_CANDIDATE"
    var token: String
    var topic: String
    var candidate: IceCandidate
    var unqiueId: String

    public init(id: String = "ADD_ICE_CANDIDATE", token: String, topic: String, candidate: IceCandidate) {
        self.id = id
        self.token = token
        self.topic = topic
        self.candidate = candidate
        unqiueId = UUID().uuidString
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case token
        case topic
        case candidate = "candidateDto"
        case unqiueId
    }
}
