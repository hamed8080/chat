//
// StopAllSessionReq.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  StopAllSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import FanapPodAsyncSDK

struct StopAllSessionReq: Codable, AsyncSnedable {
    var id: String = "STOPALL"
    var token: String
    var peerName: String?
    var content: String? { convertCodableToString() }
    var asyncMessageType: AsyncMessageTypes? = .message

    public init(peerName: String, token: String) {
        self.token = token
        self.peerName = peerName
    }
}
