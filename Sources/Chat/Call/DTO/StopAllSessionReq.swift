//
// StopAllSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct StopAllSessionReq: Codable, AsyncSnedable {
    var id: String = "STOPALL"
    var token: String
    var peerName: String?
    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message

    public init(peerName: String, token: String) {
        self.token = token
        self.peerName = peerName
    }
}
