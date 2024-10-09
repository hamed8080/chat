//
// AsyncMessageTypes.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// Whenever an event occurs in the server or you want to send a message, a type of message will tell you what's happening right now.
public enum AsyncMessageTypes: Int, Codable, Identifiable, CaseIterable {
    public var id: Self { self }
    /// Ping every 20 seonds to keep socket alive.
    case ping = 0

    /// Register with server.
    case serverRegister = 1

    /// Registered with server.
    case deviceRegister = 2

    /// A message  was received.
    case message = 3

    /// A message that needs acknowledgment to tell the server Hey I received the message. It's two-directional.
    case messageAckNeeded = 4

    /// The server needs to know if you receiving this message you should tell us.
    case messageSenderAckNeeded = 5

    /// An acknowledgment of a message.
    case ack = 6

    /// Not implemended.
    case getRegisteredPeers = 7

    /// Not implemended.
    case peerRemoved = -3

    /// Not implemended.
    case registerQueue = -2

    /// Not implemended.
    case notRegistered = -1

    /// Not implemended.
    case errorMessage = -99
}
