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

struct StopAllSessionReq: Codable {
    var id: String = "STOPALL"
    var token: String

    public init(token: String) {
        self.token = token
    }
}
