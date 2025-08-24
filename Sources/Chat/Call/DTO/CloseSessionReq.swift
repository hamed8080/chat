//
// CloseSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct CloseSessionReq: Codable, AsyncSnedable {
    var id: String = "CLOSE"
    var token: String
    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message
    var peerName: String?

    public init(peerName: String, token: String) {
        self.token = token
        self.peerName = peerName
    }
}
