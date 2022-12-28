//
// ChatConfig.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import FanapPodAsyncSDK
import Foundation

public struct ChatConfig {
    var asyncConfig: AsyncConfig
    var ssoHost: String
    var platformHost: String
    var fileServer: String
    var podSpaceFileServerAddress: String = "https://podspace.pod.ir"
    var token: String
    var mapApiKey: String?
    var mapServer: String = "https://api.neshan.org/v1"
    var typeCode: String = "default"
    var enableCache: Bool = false
    var cacheTimeStampInSec: Int = (2 * 24) * (60 * 60)
    var msgPriority: Int = 1
    var msgTTL: Int = 10
    var httpRequestTimeout: Int = 20
    var wsConnectionWaitTime: Double = 0.0
    var captureLogsOnSentry: Bool = false
    var maxReconnectTimeInterval: Int = 60
    var localImageCustomPath: URL?
    var localFileCustomPath: URL?
    var deviecLimitationSpaceMB: Int64 = 100
    var getDeviceIdFromToken: Bool = false
    var isDebuggingLogEnabled: Bool = false
    var enableNotificationLogObserver: Bool = false

    // Memberwise Initializer
    public init(
        asyncConfig: AsyncConfig,
        token: String,
        ssoHost: String,
        platformHost: String,
        fileServer: String,
        podSpaceFileServerAddress _: String = "https://podspace.pod.ir",
        mapApiKey: String? = nil,
        mapServer: String = "https://api.neshan.org/v1",
        typeCode: String = "default",
        enableCache: Bool = false,
        cacheTimeStampInSec: Int = (2 * 24) * (60 * 60),
        msgPriority: Int = 1,
        msgTTL: Int = 10,
        httpRequestTimeout: Int = 20,
        wsConnectionWaitTime: Double = 0.0,
        captureLogsOnSentry: Bool = false,
        maxReconnectTimeInterval: Int = 60,
        localImageCustomPath: URL? = nil,
        localFileCustomPath: URL? = nil,
        deviecLimitationSpaceMB: Int64 = 100,
        getDeviceIdFromToken: Bool = false,
        isDebuggingLogEnabled: Bool = false,
        enableNotificationLogObserver: Bool = false
    ) {
        self.asyncConfig = asyncConfig
        self.ssoHost = ssoHost
        self.platformHost = platformHost
        self.fileServer = fileServer
        self.token = token
        self.mapApiKey = mapApiKey
        self.mapServer = mapServer
        self.typeCode = typeCode
        self.enableCache = enableCache
        self.cacheTimeStampInSec = cacheTimeStampInSec
        self.msgPriority = msgPriority
        self.msgTTL = msgTTL
        self.httpRequestTimeout = httpRequestTimeout
        self.wsConnectionWaitTime = wsConnectionWaitTime
        self.captureLogsOnSentry = captureLogsOnSentry
        self.maxReconnectTimeInterval = maxReconnectTimeInterval
        self.localImageCustomPath = localImageCustomPath
        self.localFileCustomPath = localFileCustomPath
        self.deviecLimitationSpaceMB = deviecLimitationSpaceMB
        self.getDeviceIdFromToken = getDeviceIdFromToken
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        self.enableNotificationLogObserver = enableNotificationLogObserver
    }
}

public class ChatConfigBuilder {
    private(set) var asyncConfig: AsyncConfig
    private(set) var ssoHost: String = ""
    private(set) var platformHost: String = ""
    private(set) var fileServer: String = ""
    private(set) var podSpaceFileServerAddress: String = "https://podspace.pod.ir"
    private(set) var token: String = ""
    private(set) var mapApiKey: String?
    private(set) var mapServer: String = "https://api.neshan.org/v1"
    private(set) var typeCode: String = "default"
    private(set) var enableCache: Bool = false
    private(set) var cacheTimeStampInSec: Int = (2 * 24) * (60 * 60)
    private(set) var msgPriority: Int = 1
    private(set) var msgTTL: Int = 10
    private(set) var httpRequestTimeout: Int = 20
    private(set) var wsConnectionWaitTime: Double = 0.0
    private(set) var captureLogsOnSentry: Bool = false
    private(set) var maxReconnectTimeInterval: Int = 60
    private(set) var localImageCustomPath: URL?
    private(set) var localFileCustomPath: URL?
    private(set) var deviecLimitationSpaceMB: Int64 = 100
    private(set) var getDeviceIdFromToken: Bool = false
    private(set) var isDebuggingLogEnabled: Bool = false
    private(set) var enableNotificationLogObserver: Bool = false

    public init(_ asyncConfig: AsyncConfig) {
        self.asyncConfig = asyncConfig
    }

    @discardableResult public func ssoHost(_ ssoHost: String) -> ChatConfigBuilder {
        self.ssoHost = ssoHost
        return self
    }

    @discardableResult public func platformHost(_ platformHost: String) -> ChatConfigBuilder {
        self.platformHost = platformHost
        return self
    }

    @discardableResult public func fileServer(_ fileServer: String) -> ChatConfigBuilder {
        self.fileServer = fileServer
        return self
    }

    @discardableResult public func podSpaceFileServerAddress(_ podSpaceFileServerAddress: String) -> ChatConfigBuilder {
        self.podSpaceFileServerAddress = podSpaceFileServerAddress
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

    @discardableResult public func mapServer(_ mapServer: String) -> ChatConfigBuilder {
        self.mapServer = mapServer
        return self
    }

    @discardableResult public func typeCode(_ typeCode: String) -> ChatConfigBuilder {
        self.typeCode = typeCode
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

    @discardableResult public func captureLogsOnSentry(_ captureLogsOnSentry: Bool) -> ChatConfigBuilder {
        self.captureLogsOnSentry = captureLogsOnSentry
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

    @discardableResult public func isDebuggingLogEnabled(_ isDebuggingLogEnabled: Bool) -> ChatConfigBuilder {
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        return self
    }

    @discardableResult public func enableNotificationLogObserver(_ enableNotificationLogObserver: Bool) -> ChatConfigBuilder {
        self.enableNotificationLogObserver = enableNotificationLogObserver
        return self
    }

    public func build() -> ChatConfig {
        ChatConfig(
            asyncConfig: asyncConfig,
            token: token,
            ssoHost: ssoHost,
            platformHost: platformHost,
            fileServer: fileServer,
            podSpaceFileServerAddress: podSpaceFileServerAddress,
            mapApiKey: mapApiKey,
            mapServer: mapServer,
            typeCode: typeCode,
            enableCache: enableCache,
            cacheTimeStampInSec: cacheTimeStampInSec,
            msgPriority: msgPriority,
            msgTTL: msgTTL,
            httpRequestTimeout: httpRequestTimeout,
            wsConnectionWaitTime: wsConnectionWaitTime,
            captureLogsOnSentry: captureLogsOnSentry,
            maxReconnectTimeInterval: maxReconnectTimeInterval,
            localImageCustomPath: localImageCustomPath,
            localFileCustomPath: localFileCustomPath,
            deviecLimitationSpaceMB: deviecLimitationSpaceMB,
            getDeviceIdFromToken: getDeviceIdFromToken,
            isDebuggingLogEnabled: isDebuggingLogEnabled,
            enableNotificationLogObserver: enableNotificationLogObserver
        )
    }
}
