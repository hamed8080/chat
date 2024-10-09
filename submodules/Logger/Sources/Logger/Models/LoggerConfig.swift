//
// LoggerConfig.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct LoggerConfig: Codable {
    public private(set) var prefix: String
    public private(set) var logServerURL: String?
    public private(set) var logServerMethod: String = "POST"
    public private(set) var logServerRequestheaders = [String: String]()
    public private(set) var persistLogsOnServer: Bool = false
    public private(set) var sendLogInterval: TimeInterval = 60

    /// - isDebuggingLogEnabled: If debugging is set true in the console you'll see logs for messages that send and receive and also what's happening when the socket state changes.
    public private(set) var isDebuggingLogEnabled: Bool = false

    /// - isDebuggingLogEnabled: If debugging is set true in the console you'll see logs for messages that send and receive and also what's happening when the socket state changes.
    public init(prefix: String,
                logServerURL: String? = nil,
                logServerMethod: String = "POST",
                persistLogsOnServer: Bool = false,
                isDebuggingLogEnabled: Bool = false,
                sendLogInterval: TimeInterval = 60,
                logServerRequestheaders: [String: String] = [:])
    {
        self.prefix = prefix
        self.logServerURL = logServerURL
        self.logServerMethod = logServerMethod
        self.persistLogsOnServer = persistLogsOnServer
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        self.sendLogInterval = sendLogInterval
        self.logServerRequestheaders = logServerRequestheaders
    }
}

public final class LoggerConfigBuilder {
    private(set) var prefix: String
    private(set) var logServerURL: String?
    private(set) var logServerMethod: String = "POST"
    private(set) var logServerRequestheaders = [String: String]()
    private(set) var persistLogsOnServer: Bool = false
    private(set) var sendLogInterval: TimeInterval = 60
    private(set) var isDebuggingLogEnabled: Bool = false

    public init(prefix: String) {
        self.prefix = prefix
    }

    @discardableResult
    public func logServerURL(_ logServerURL: String) -> LoggerConfigBuilder {
        self.logServerURL = logServerURL
        return self
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
        LoggerConfig(prefix: prefix,
                     logServerURL: logServerURL,
                     logServerMethod: logServerMethod,
                     persistLogsOnServer: persistLogsOnServer,
                     isDebuggingLogEnabled: isDebuggingLogEnabled,
                     sendLogInterval: sendLogInterval,
                     logServerRequestheaders: logServerRequestheaders)
    }
}
