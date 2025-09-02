//
// CloseSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import ChatCore

struct CloseSessionReq: Codable {
    let id: CallMessageType = .close
    let token: String

    public init(token: String) {
        self.token = token
    }
}
