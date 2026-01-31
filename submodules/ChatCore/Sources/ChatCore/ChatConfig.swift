//
// ChatConfig.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation
import Logger
import Spec

public struct ChatConfig: Codable, Sendable {
    public var spec: Spec
    public var asyncConfig: AsyncConfig
    public private(set) var callConfig: CallConfig
    public private(set) var token: String
    public private(set) var mapApiKey: String?
    public private(set) var typeCodes: [OwnerTypeCode] = []
    public private(set) var enableCache: Bool = false
    public private(set) var cacheTimeStampInSec: Int = (2 * 24) * (60 * 60)
    public private(set) var msgPriority: Int = 1
    public private(set) var msgTTL: Int = 10
    public private(set) var httpRequestTimeout: Int = 20
    public private(set) var wsConnectionWaitTime: Double = 0.0
    /// Caution: If you enable this most errors and important logs of the SDK will store in Core Data
    /// and then they will send to the server by a queue.
    public private(set) var persistLogsOnServer: Bool = false
    public private(set) var maxReconnectTimeInterval: Int = 60
    public private(set) var localImageCustomPath: URL?
    public private(set) var localFileCustomPath: URL?
    public private(set) var deviecLimitationSpaceMB: Int64 = 100
    public private(set) var getDeviceIdFromToken: Bool = false
    public private(set) var appGroup: String?
    public private(set) var saveOnUpload: Bool = true
    /// With Enabling queue you have the option to retry a message when a message fails to send in times there is a connection error.
    public private(set) var enableQueue: Bool = false
    public private(set) var loggerConfig: LoggerConfig

    // Memberwise Initializer
    public init(
        spec: Spec,
        asyncConfig: AsyncConfig,
        callConfig: CallConfig,
        token: String,
        mapApiKey: String? = nil,
        typeCodes: [OwnerTypeCode] = [],
        enableCache: Bool = false,
        cacheTimeStampInSec: Int = (2 * 24) * (60 * 60),
        msgPriority: Int = 1,
        msgTTL: Int = 10,
        httpRequestTimeout: Int = 20,
        wsConnectionWaitTime: Double = 0.0,
        persistLogsOnServer: Bool = false,
        maxReconnectTimeInterval: Int = 60,
        localImageCustomPath: URL? = nil,
        localFileCustomPath: URL? = nil,
        deviecLimitationSpaceMB: Int64 = 100,
        getDeviceIdFromToken: Bool = false,
        appGroup: String? = nil,
        saveOnUpload: Bool = true,
        enableQueue: Bool = false,
        loggerConfig: LoggerConfig? = nil
    ) {
        self.spec = spec
        self.asyncConfig = asyncConfig
        self.callConfig = callConfig
        self.token = token
        self.mapApiKey = mapApiKey
        self.typeCodes.append(contentsOf: typeCodes)
        if self.typeCodes.count == 0 {
            fatalError("You have to pass at least one type code!")
        }
        self.enableCache = enableCache
        self.cacheTimeStampInSec = cacheTimeStampInSec
        self.msgPriority = msgPriority
        self.msgTTL = msgTTL
        self.httpRequestTimeout = httpRequestTimeout
        self.wsConnectionWaitTime = wsConnectionWaitTime
        self.persistLogsOnServer = persistLogsOnServer
        self.maxReconnectTimeInterval = maxReconnectTimeInterval
        self.localImageCustomPath = localImageCustomPath
        self.localFileCustomPath = localFileCustomPath
        self.deviecLimitationSpaceMB = deviecLimitationSpaceMB
        self.getDeviceIdFromToken = getDeviceIdFromToken
        self.appGroup = appGroup
        self.saveOnUpload = saveOnUpload
        self.enableQueue = enableQueue
        self.loggerConfig = loggerConfig ?? LoggerConfig(spec: spec, prefix: "CHAT_SDK")
    }

    public mutating func updateToken(_ token: String) {
        self.token = token
    }

    enum CodingKeys: String, CodingKey {
        case spec
        case asyncConfig
        case callConfig
        case ssoHost
        case platformHost
        case fileServer
        case podSpaceFileServerAddress
        case token
        case mapApiKey
        case mapServer
        case typeCodes
        case enableCache
        case cacheTimeStampInSec
        case msgPriority
        case msgTTL
        case httpRequestTimeout
        case wsConnectionWaitTime
        case persistLogsOnServer
        case maxReconnectTimeInterval
        case localImageCustomPath
        case localFileCustomPath
        case deviecLimitationSpaceMB
        case getDeviceIdFromToken
        case appGroup
        case saveOnUpload
        case enableQueue
        case loggerConfig
        case oldTypeCode = "typeCode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.spec = try container.decode(Spec.self, forKey: .spec)
        self.asyncConfig = try container.decode(AsyncConfig.self, forKey: .asyncConfig)
        self.callConfig = try container.decode(CallConfig.self, forKey: .callConfig)
        self.token = try container.decode(String.self, forKey: .token)
        self.mapApiKey = try container.decodeIfPresent(String.self, forKey: .mapApiKey)
        self.typeCodes = try container.decodeIfPresent([OwnerTypeCode].self, forKey: .typeCodes) ?? []
        if typeCodes.count == 0, let oldTypeCode = try? container.decodeIfPresent(String.self, forKey: .oldTypeCode) {
            typeCodes = [.init(typeCode: oldTypeCode, ownerId: nil)]
        }
        self.enableCache = try container.decode(Bool.self, forKey: .enableCache)
        self.cacheTimeStampInSec = try container.decode(Int.self, forKey: .cacheTimeStampInSec)
        self.msgPriority = try container.decode(Int.self, forKey: .msgPriority)
        self.msgTTL = try container.decode(Int.self, forKey: .msgTTL)
        self.httpRequestTimeout = try container.decode(Int.self, forKey: .httpRequestTimeout)
        self.wsConnectionWaitTime = try container.decode(Double.self, forKey: .wsConnectionWaitTime)
        self.persistLogsOnServer = try container.decode(Bool.self, forKey: .persistLogsOnServer)
        self.maxReconnectTimeInterval = try container.decode(Int.self, forKey: .maxReconnectTimeInterval)
        self.localImageCustomPath = try container.decodeIfPresent(URL.self, forKey: .localImageCustomPath)
        self.localFileCustomPath = try container.decodeIfPresent(URL.self, forKey: .localFileCustomPath)
        self.deviecLimitationSpaceMB = try container.decode(Int64.self, forKey: .deviecLimitationSpaceMB)
        self.getDeviceIdFromToken = try container.decode(Bool.self, forKey: .getDeviceIdFromToken)
        self.appGroup = try container.decodeIfPresent(String.self, forKey: .appGroup)
        self.saveOnUpload = try container.decodeIfPresent(Bool.self, forKey: .saveOnUpload) ?? true
        self.enableQueue = try container.decode(Bool.self, forKey: .enableQueue)
        self.loggerConfig = try container.decode(LoggerConfig.self, forKey: .loggerConfig)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(spec, forKey: .spec)
        try container.encodeIfPresent(asyncConfig, forKey: .asyncConfig)
        try container.encodeIfPresent(callConfig, forKey: .callConfig)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(mapApiKey, forKey: .mapApiKey)
        try container.encodeIfPresent(typeCodes, forKey: .typeCodes)
        try container.encodeIfPresent(enableCache, forKey: .enableCache)
        try container.encodeIfPresent(cacheTimeStampInSec, forKey: .cacheTimeStampInSec)
        try container.encodeIfPresent(msgPriority, forKey: .msgPriority)
        try container.encodeIfPresent(msgTTL, forKey: .msgTTL)
        try container.encodeIfPresent(httpRequestTimeout, forKey: .httpRequestTimeout)
        try container.encodeIfPresent(wsConnectionWaitTime, forKey: .wsConnectionWaitTime)
        try container.encodeIfPresent(persistLogsOnServer, forKey: .persistLogsOnServer)
        try container.encodeIfPresent(maxReconnectTimeInterval, forKey: .maxReconnectTimeInterval)
        try container.encodeIfPresent(localImageCustomPath, forKey: .localImageCustomPath)
        try container.encodeIfPresent(localFileCustomPath, forKey: .localFileCustomPath)
        try container.encodeIfPresent(deviecLimitationSpaceMB, forKey: .deviecLimitationSpaceMB)
        try container.encodeIfPresent(getDeviceIdFromToken, forKey: .getDeviceIdFromToken)
        try container.encodeIfPresent(appGroup, forKey: .appGroup)
        try container.encodeIfPresent(saveOnUpload, forKey: .saveOnUpload)
        try container.encodeIfPresent(enableQueue, forKey: .enableQueue)
        try container.encodeIfPresent(loggerConfig, forKey: .loggerConfig)
    }
}

public final class ChatConfigBuilder {
    private(set) var spec: Spec
    private(set) var asyncConfig: AsyncConfig
    private(set) var callConfig: CallConfig = CallConfigBuilder().build()
    private(set) var token: String = ""
    private(set) var mapApiKey: String?
    private(set) var typeCodes: [OwnerTypeCode] = []
    private(set) var enableCache: Bool = false
    private(set) var cacheTimeStampInSec: Int = (2 * 24) * (60 * 60)
    private(set) var msgPriority: Int = 1
    private(set) var msgTTL: Int = 10
    private(set) var httpRequestTimeout: Int = 20
    private(set) var wsConnectionWaitTime: Double = 0.0
    private(set) var persistLogsOnServer: Bool = false
    private(set) var maxReconnectTimeInterval: Int = 60
    private(set) var localImageCustomPath: URL?
    private(set) var localFileCustomPath: URL?
    private(set) var deviecLimitationSpaceMB: Int64 = 100
    private(set) var getDeviceIdFromToken: Bool = false
    private(set) var appGroup: String?
    private(set) var saveOnUpload: Bool = true
    private(set) var enableQueue: Bool = false
    private(set) var loggerConfig: LoggerConfig

    public init(spec: Spec, _ asyncConfig: AsyncConfig) {
        self.spec = spec
        self.asyncConfig = asyncConfig
        self.loggerConfig = LoggerConfig(spec: spec, prefix: "CHAT_SDK")
    }

    @discardableResult public func callConfig(_ callConfig: CallConfig) -> ChatConfigBuilder {
        self.callConfig = callConfig
        return self
    }

    @discardableResult public func token(_ token: String) -> ChatConfigBuilder {
        self.token = token
        return self
    }

    @discardableResult public func mapApiKey(_ mapApiKey: String?) -> ChatConfigBuilder {
        self.mapApiKey = mapApiKey
        return self
    }

    @discardableResult public func typeCodes(_ typeCodes: [OwnerTypeCode]) -> ChatConfigBuilder {
        self.typeCodes = typeCodes
        return self
    }

    @discardableResult public func enableCache(_ enableCache: Bool) -> ChatConfigBuilder {
        self.enableCache = enableCache
        return self
    }

    @discardableResult public func cacheTimeStampInSec(_ cacheTimeStampInSec: Int) -> ChatConfigBuilder {
        self.cacheTimeStampInSec = cacheTimeStampInSec
        return self
    }

    @discardableResult public func msgPriority(_ msgPriority: Int) -> ChatConfigBuilder {
        self.msgPriority = msgPriority
        return self
    }

    @discardableResult public func msgTTL(_ msgTTL: Int) -> ChatConfigBuilder {
        self.msgTTL = msgTTL
        return self
    }

    @discardableResult public func httpRequestTimeout(_ httpRequestTimeout: Int) -> ChatConfigBuilder {
        self.httpRequestTimeout = httpRequestTimeout
        return self
    }

    @discardableResult public func wsConnectionWaitTime(_ wsConnectionWaitTime: Double) -> ChatConfigBuilder {
        self.wsConnectionWaitTime = wsConnectionWaitTime
        return self
    }

    @discardableResult public func persistLogsOnServer(_ persistLogsOnServer: Bool) -> ChatConfigBuilder {
        self.persistLogsOnServer = persistLogsOnServer
        return self
    }

    @discardableResult public func maxReconnectTimeInterval(_ maxReconnectTimeInterval: Int) -> ChatConfigBuilder {
        self.maxReconnectTimeInterval = maxReconnectTimeInterval
        return self
    }

    @discardableResult public func localImageCustomPath(_ localImageCustomPath: URL?) -> ChatConfigBuilder {
        self.localImageCustomPath = localImageCustomPath
        return self
    }

    @discardableResult public func localFileCustomPath(_ localFileCustomPath: URL?) -> ChatConfigBuilder {
        self.localFileCustomPath = localFileCustomPath
        return self
    }

    @discardableResult public func deviecLimitationSpaceMB(_ deviecLimitationSpaceMB: Int64) -> ChatConfigBuilder {
        self.deviecLimitationSpaceMB = deviecLimitationSpaceMB
        return self
    }

    @discardableResult public func getDeviceIdFromToken(_ getDeviceIdFromToken: Bool) -> ChatConfigBuilder {
        self.getDeviceIdFromToken = getDeviceIdFromToken
        return self
    }

    @discardableResult public func appGroup(_ appGroup: String) -> ChatConfigBuilder {
        self.appGroup = appGroup
        return self
    }

    @discardableResult public func saveOnUpload(_ saveOnUpload: Bool) -> ChatConfigBuilder {
        self.saveOnUpload = saveOnUpload
        return self
    }

    @discardableResult public func enableQueue(_ enableQueue: Bool) -> ChatConfigBuilder {
        self.enableQueue = enableQueue
        return self
    }

    @discardableResult public func loggerConfig(_ loggerConfig: LoggerConfig) -> ChatConfigBuilder {
        self.loggerConfig = loggerConfig
        return self
    }

    public func build() -> ChatConfig {
        ChatConfig(
            spec: spec,
            asyncConfig: asyncConfig,
            callConfig: callConfig,
            token: token,
            mapApiKey: mapApiKey,
            typeCodes: typeCodes,
            enableCache: enableCache,
            cacheTimeStampInSec: cacheTimeStampInSec,
            msgPriority: msgPriority,
            msgTTL: msgTTL,
            httpRequestTimeout: httpRequestTimeout,
            wsConnectionWaitTime: wsConnectionWaitTime,
            persistLogsOnServer: persistLogsOnServer,
            maxReconnectTimeInterval: maxReconnectTimeInterval,
            localImageCustomPath: localImageCustomPath,
            localFileCustomPath: localFileCustomPath,
            deviecLimitationSpaceMB: deviecLimitationSpaceMB,
            getDeviceIdFromToken: getDeviceIdFromToken,
            appGroup: appGroup,
            saveOnUpload: saveOnUpload,
            enableQueue: enableQueue,
            loggerConfig: loggerConfig
        )
    }
}
