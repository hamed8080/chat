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
    var actualTimingLog: Bool = false
    var wsConnectionWaitTime: Double = 0.0
    var captureLogsOnSentry: Bool = false
    var maxReconnectTimeInterval: Int = 60
    var localImageCustomPath: URL?
    var localFileCustomPath: URL?
    var deviecLimitationSpaceMB: Int64 = 100
    var getDeviceIdFromToken: Bool = false
    var isDebuggingLogEnabled: Bool = false
    var enableNotificationLogObserver: Bool = false
    var callTimeout: TimeInterval = 45

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
        actualTimingLog: Bool = false,
        wsConnectionWaitTime: Double = 0.0,
        captureLogsOnSentry: Bool = false,
        maxReconnectTimeInterval: Int = 60,
        localImageCustomPath: URL? = nil,
        localFileCustomPath: URL? = nil,
        deviecLimitationSpaceMB: Int64 = 100,
        getDeviceIdFromToken: Bool = false,
        isDebuggingLogEnabled: Bool = false,
        enableNotificationLogObserver: Bool = false,
        callTimeout: TimeInterval = 45
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
        self.actualTimingLog = actualTimingLog
        self.wsConnectionWaitTime = wsConnectionWaitTime
        self.captureLogsOnSentry = captureLogsOnSentry
        self.maxReconnectTimeInterval = maxReconnectTimeInterval
        self.localImageCustomPath = localImageCustomPath
        self.localFileCustomPath = localFileCustomPath
        self.deviecLimitationSpaceMB = deviecLimitationSpaceMB
        self.getDeviceIdFromToken = getDeviceIdFromToken
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        self.enableNotificationLogObserver = enableNotificationLogObserver
        self.callTimeout = callTimeout
    }
}
