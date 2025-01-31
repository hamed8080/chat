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
    
    init(deviceModel: String, os: String = "iOS", osVersion: String, sdkVersion: String = "1.0.0", bundleIdentifire: String?) {
        self.deviceModel = deviceModel
        self.os = os
        self.osVersion = osVersion
        self.sdkVersion = sdkVersion
        self.bundleIdentifire = bundleIdentifire
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
        if let deviceInfo = deviceInfo {
            dic[LoggerUserInfosKeys.deviceInfo.rawValue] = deviceInfo.string?.prettyJsonString()
        }
        return dic
    }

    func setDeviceInfo() async {
        let tuple = await deviceInfo()
        deviceInfo = DeviceInfo(deviceModel: tuple.deviceModel, os: "iOS", osVersion: tuple.osVersion, sdkVersion: "1.0.0", bundleIdentifire: tuple.bundleIdentifire)
    }
    
    @MainActor
    func deviceInfo() async -> (bundleIdentifire: String?, osVersion: String, deviceModel: String) {
        let bundle = Bundle.main.bundleIdentifier
        var osVersion = ""
        var deviceModel = ""
#if canImport(UIKit)
        osVersion = UIDevice.current.systemVersion
        deviceModel = UIDevice.current.model
#endif
        return (bundle, osVersion, deviceModel)
    }
}
