//
// CloseSessionReq.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  CloseSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import FanapPodAsyncSDK
import Foundation

struct CloseSessionReq: Codable, AsyncSnedable {
    var id: String = "CLOSE"
    var token: String
    var content: String? { convertCodableToString() }
    var asyncMessageType: AsyncMessageTypes? = .message
    var peerName: String?

    public init(peerName: String, token: String) {
        self.token = token
        self.peerName = peerName
    }
}
