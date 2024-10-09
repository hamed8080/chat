//
// AsyncStateModel.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// This struct only manages the state of the connection and persists all values that need for the async state.
struct AsyncStateModel {
    /// A boolean that indicates the device is successfully registered with the async server.
    var isServerRegistered: Bool = false

    /// A boolean that indicates the device is successfully registered.
    var isDeviceRegistered: Bool = false

    /// The number of retries that have happened to connect to the async server.
    var retryCount: Int = 0

    /// The peerId of, which will be filled after the device is registered.
    private(set) var peerId: Int?

    /// The state of the current socket.
    private(set) var socketState: AsyncSocketState = .closed

    /// The device id, it'll be set after the device is registered.
    private(set) var deviceId: String?

    /// Old deviceId is needed upon any recoonect because we send refresh true, ad it does need old device id unless it will disconnect us.
    private(set) var oldDeviceId: String?

    /// The last message receive-date to track ping intervals.
    private(set) var lastMessageRCVDate: Date?

    /// Setter for the state of the connection.
    mutating func setSocketState(socketState: AsyncSocketState) {
        self.socketState = socketState
    }

    /// Setter for the deviceId.
    mutating func setDeviceId(deviceId: String?) {
        self.oldDeviceId = self.deviceId
        self.deviceId = deviceId
    }

    /// Setter for the peerId.
    mutating func setPeerId(peerId: Int?) {
        self.peerId = peerId
    }

    /// Updater for the last message date received.
    mutating func setLastMessageReceiveDate() {
        lastMessageRCVDate = Date()
    }
}
