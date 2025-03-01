//
// LoggerConfig.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import Spec

public struct LoggerConfig: Codable, Sendable {
    public let spec: Spec
    public private(set) var prefix: String
    public private(set) var logServerMethod: String = "POST"
    public private(set) var logServerRequestheaders = [String: String]()
    public private(set) var persistLogsOnServer: Bool = false
    public private(set) var sendLogInterval: TimeInterval = 60

    /// - isDebuggingLogEnabled: If debugging is set true in the console you'll see logs for messages that send and receive and also what's happening when the socket state changes.
    public private(set) var isDebuggingLogEnabled: Bool = false

    /// - isDebuggingLogEnabled: If debugging is set true in the console you'll see logs for messages that send and receive and also what's happening when the socket state changes.
    public init(spec: Spec,
                prefix: String,
                logServerMethod: String = "POST",
                persistLogsOnServer: Bool = false,
                isDebuggingLogEnabled: Bool = false,
                sendLogInterval: TimeInterval = 60,
                logServerRequestheaders: [String: String] = [:])
    {
        self.spec = spec
        self.prefix = prefix
        self.logServerMethod = logServerMethod
        self.persistLogsOnServer = persistLogsOnServer
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        self.sendLogInterval = sendLogInterval
        self.logServerRequestheaders = logServerRequestheaders
    }
}

public final class LoggerConfigBuilder {
    private(set) var spec: Spec
    private(set) var prefix: String
    private(set) var logServerMethod: String = "POST"
    private(set) var logServerRequestheaders = [String: String]()
    private(set) var persistLogsOnServer: Bool = false
    private(set) var sendLogInterval: TimeInterval = 60
    private(set) var isDebuggingLogEnabled: Bool = false

    public init(spec: Spec, prefix: String) {
        self.spec = spec
        self.prefix = prefix
    }

    @discardableResult
    public func logServerMethod(_ logServerMethod: String) -> LoggerConfigBuilder {
        self.logServerMethod = logServerMethod
        return self
    }

    @discardableResult
    public func logServerRequestheaders(_ logServerRequestheaders: [String: String]) -> LoggerConfigBuilder {
        self.logServerRequestheaders = logServerRequestheaders
        return self
    }

    @discardableResult
    public func persistLogsOnServer(_ persistLogsOnServer: Bool) -> LoggerConfigBuilder {
        self.persistLogsOnServer = persistLogsOnServer
        return self
    }

    @discardableResult
    public func sendLogInterval(_ sendLogInterval: TimeInterval) -> LoggerConfigBuilder {
        self.sendLogInterval = sendLogInterval
        return self
    }

    @discardableResult
    public func isDebuggingLogEnabled(_ isDebuggingLogEnabled: Bool) -> LoggerConfigBuilder {
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        return self
    }

    public func build() -> LoggerConfig {
        LoggerConfig(spec: spec,
                     prefix: prefix,
                     logServerMethod: logServerMethod,
                     persistLogsOnServer: persistLogsOnServer,
                     isDebuggingLogEnabled: isDebuggingLogEnabled,
                     sendLogInterval: sendLogInterval,
                     logServerRequestheaders: logServerRequestheaders)
    }
}
