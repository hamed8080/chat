//
// RegisterDevice.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

/// A struct of the request/response for registering the device with the server.
struct RegisterDevice: Codable {
    /// A boolean is set to true if the peerId has never set before.
    var renew: Bool?

    /// A boolean is set to true if the peerId has set before and has a value.
    var refresh: Bool?

    /// This `appId` will be gained by the configuration.
    var appId: String

    /// Device id.
    var deviceId: String

    /// A boolean is set to true if the peerId has been set before and has a value, otherwise, the other initializer will be used with the refresh.
    public init(renew: Bool, appId: String, deviceId: String) {
        self.renew = renew
        refresh = false
        self.appId = appId
        self.deviceId = deviceId
    }

    /// A boolean is set to true if the peerId has been set before and has a value, otherwise, the other initializer will be used with renewing.
    public init(refresh: Bool, appId: String, deviceId: String) {
        // We should set renew to false to retrieve old messages from.
        renew = false
        self.refresh = refresh
        self.appId = appId
        self.deviceId = deviceId
    }
}
