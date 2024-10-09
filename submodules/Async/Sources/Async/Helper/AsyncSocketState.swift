//
// AsyncSocketState.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// The current state of the socket.
public enum AsyncSocketState: String, Identifiable, CaseIterable {
    public var id: Self { self }
    /// The socket is trying to connect again.
    case connecting

    /// The socket is already connected.
    case connected

    /// The socket closed due to weak internet connectivity or an error that had happened on the server.
    case closed

    /// Async is ready to use.
    case asyncReady
}
