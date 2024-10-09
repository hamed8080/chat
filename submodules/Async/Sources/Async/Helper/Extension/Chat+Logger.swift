//
// Chat+Logger.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public struct DeviceInfo: Codable {
    let deviceModel: String
    let os: String
    let osVersion: String
    let sdkVersion: String
    let bundleIdentifire: String?

    static func getDeviceInfo() -> DeviceInfo {
        let bundle = Bundle.main.bundleIdentifier
        var osVersion = ""
        var deviceModel = ""
        #if canImport(UIKit)
            osVersion = UIDevice.current.systemVersion
            deviceModel = UIDevice.current.model
        #endif
        return DeviceInfo(deviceModel: deviceModel, os: "iOS", osVersion: osVersion, sdkVersion: "1.0.0", bundleIdentifire: bundle)
    }
}

extension Async {
    enum LoggerUserInfosKeys: String {
        case config
        case deviceInfo
    }

    var loggerUserInfo: [String: String] {
        var dic = [String: String]()
        dic[LoggerUserInfosKeys.config.rawValue] = config.string?.prettyJsonString()
        dic[LoggerUserInfosKeys.deviceInfo.rawValue] = DeviceInfo.getDeviceInfo().string?.prettyJsonString()
        return dic
    }
}
