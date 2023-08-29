//
// CustomLog.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public protocol LoggerDelegate: AnyObject {
    func onLog(log: Log)
}

public struct DeviceInfo: Codable {
    let deviceModel: String
    let os: String
    let osVersion: String
    let sdkVersion: String
    let bundleIdentifire: String

    static func getDeviceInfo() -> DeviceInfo {
        let bundle = Bundle.main.bundleIdentifier
        var osVersion = ""
        var deviceModel = ""
        #if canImport(UIKit)
            osVersion = UIDevice.current.systemVersion
            deviceModel = UIDevice.current.model
        #endif
        return DeviceInfo(deviceModel: deviceModel, os: "iOS", osVersion: osVersion, sdkVersion: "1.0.0", bundleIdentifire: bundle ?? "")
    }
}

public enum LogLevel: Int, Codable {
    case verbose = 0
    case warning = 1
    case error = 2
}

public class Logger {
    private var sdkName: String { "CHAT_SDK-\(chat?.userInfo?.id ?? 0): " }
    weak var chat: ChatProtocol?
    private var urlSession: URLSessionProtocol
    private var config: ChatConfig? { chat?.config }
    private var timer: TimerProtocol?

    init(timer: TimerProtocol? = Timer(), urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
        self.timer = timer
    }

    func log(title: String? = nil, jsonString: String? = nil, receive _: Bool = true, persistOnServer: Bool = false) {
        if config?.isDebuggingLogEnabled == true {
            if let title = title {
                print(sdkName + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }

            if persistOnServer {
                log(message: jsonString)
            }
            print("\n")
        }
    }

    func log(title: String? = nil, message: String? = nil, persistOnServer: Bool = false) {
        if config?.isDebuggingLogEnabled == true {
            if let title = title {
                print(sdkName + title)
            }
            if let message = message {
                print(message)
            }

            if persistOnServer, let message = message {
                log(message: message)
            }
            print("\n")
        }
    }

    func log(_ request: URLRequest, _ decodeType: String) {
        if config?.isDebuggingLogEnabled == true {
            var output = "\n"
            output += "Start Of Request============================================================================================\n"
            output += " REST Request With Method:\(request.httpMethod ?? "") - url:\(request.url?.absoluteString ?? "")\n"
            output += " With Headers:\(request.allHTTPHeaderFields?.debugDescription ?? "[]")\n"
            output += " With HttpBody:\(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")\n"
            output += " Expected DecodeType:\(decodeType)\n"
            output += "End  Of  Request============================================================================================\n"
            output += "\n"
            log(title: "CHAT_SDK:", message: output)
        }
    }

    func log(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        if config?.isDebuggingLogEnabled == true {
            var output = "\n"
            output += "Start Of Response============================================================================================\n"
            output += " REST Response For url:\(response?.url?.absoluteString ?? "")\n"
            output += " With Data Result in Body:\(String(data: data ?? Data(), encoding: .utf8) ?? "nil")\n"
            output += "End  Of  Response============================================================================================\n"
            output += "\n"
            log(title: "CHAT_SDK:", message: output)
            if let error = error {
                log(message: "\(error.localizedDescription) \n\(output)", level: .error)
            }
        }
    }

    func log(message: String, level: LogLevel = .verbose) {
        let log = Log(
            message: message,
            config: config,
            deviceInfo: DeviceInfo.getDeviceInfo(),
            level: level
        )
        chat?.logDelegate?.onLog(log: log)
    }

    func startSending() {
    }

    public func dispose() {
        timer?.invalidateTimer()
        timer = nil
    }
}
