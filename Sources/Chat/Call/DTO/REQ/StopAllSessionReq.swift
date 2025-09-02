//
// StopAllSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct StopAllSessionReq: Codable {
    var id: CallMessageType = .stopAll
    var token: String

    public init(token: String) {
        self.token = token
    }
}
