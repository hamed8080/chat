//
// CustomLog.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

struct DeviceInfo: Codable {
    let deviceModel: String
    let os: String
    let osVersion: String
    let sdkVersion: String
    let bundleIdentifire: String

    static func getDeviceInfo() -> DeviceInfo {
        let bundle = Bundle.main.bundleIdentifier
        var osVersion = ""
        var deviceModel = ""
        var osName = ""
        #if canImport(UIKit)
            osVersion = UIDevice.current.systemVersion
            deviceModel = UIDevice.current.model
            osName = UIDevice.current.systemName
        #endif
        return DeviceInfo(deviceModel: deviceModel, os: osName, osVersion: osVersion, sdkVersion: "1.0.0", bundleIdentifire: bundle ?? "")
    }
}

struct Log: Codable {
    var deviceInfo: DeviceInfo
    let config: ChatConfig
    let message: String
    let time: UInt
    let level: LogLevel
}

enum LogLevel: Int, Codable {
    case verbose = 0
    case warning = 1
    case error = 2
}

class Logger {
    private let sdkName = "CHAT_SDK: "
    private var urlSession: URLSession
    private let config: ChatConfig

    init(config: ChatConfig, urlSession: URLSession = .shared) {
        self.config = config
        self.urlSession = urlSession
    }

    func log(title: String? = nil, jsonString: String? = nil, receive: Bool = true) {
        if config.isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
                log(message: jsonString)
            }
            print("\n")
        }
        sendNotificationLogIfEnabled(title: title, jsonString: jsonString?.preetyJsonString(), receive: receive)
    }

    func log(title: String? = nil, message: String? = nil) {
        if config.isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
            }
            if let message = message {
                print(message)
            }
            print("\n")
        }
    }

    func log(title: String? = nil) {
        if config.isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
                log(message: sdkName + title)
            }
            print("\n")
        }
    }

    func sendNotificationLogIfEnabled(title: String?, jsonString: String?, receive: Bool) {
        if config.enableNotificationLogObserver, let jsonString = jsonString {
            let title = "\(sdkName)\(title ?? "")\n"
            let jsonWithTitle = title + jsonString
            NotificationCenter.default.post(name: Notification.Name("log"), object: LogResult(json: jsonWithTitle, receive: receive))
        }
    }

    func log(message: String, _ level: LogLevel = .verbose) {
        let log = Log(deviceInfo: DeviceInfo.getDeviceInfo(), config: config, message: message, time: UInt(Date().timeIntervalSince1970), level: level)
        let data = try? JSONEncoder().encode(log)
        sendLog(log: data)
    }

    func sendLog(log: Data?) {
        var req = URLRequest(url: URL(string: "http://10.56.34.61:8080/1m-http-server-test-chat")!)
        req.httpMethod = HTTPMethod.put.rawValue
        req.httpBody = log
        req.allHTTPHeaderFields = ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"]
        urlSession.dataTask(with: req).resume()
    }
}
