//
// RegisterServer.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
struct RegisterServer: Codable {
    /// The name of the peer server.
    var name: String

    /// The name of the peer server.
    /// - Parameter name: The peer server name.
    public init(name: String) {
        self.name = name
    }
}
