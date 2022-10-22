//
// LogResult.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct LogResult {
    public var json: String
    public var receive: Bool

    public init(json: String, receive: Bool) {
        self.json = json
        self.receive = receive
    }
}
