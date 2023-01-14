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
    private let sdkName = "CHAT_SDK: "
    private var urlSession: URLSession
    private let config: ChatConfig
    var persistentManager: PersistentManager?
    private let timer: Timer

    init(config: ChatConfig, timer: Timer = Timer(), urlSession: URLSession = .shared) {
        self.timer = timer
        self.config = config
        self.urlSession = urlSession
        if config.persistLogsOnServer {
            startSending()
        }
    }

    func log(title: String? = nil, jsonString: String? = nil, receive _: Bool = true, persistOnServer: Bool = false) {
        if config.isDebuggingLogEnabled {
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
        if config.isDebuggingLogEnabled {
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
        if config.isDebuggingLogEnabled == true {
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
        if config.isDebuggingLogEnabled == true {
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
        if config.persistLogsOnServer {
            let log = Log(
                message: message,
                config: config,
                deviceInfo: DeviceInfo.getDeviceInfo(),
                level: level
            )
            addLogTocache(log)
        }
    }

    private func startSending() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            if let pm = self?.persistentManager, let log = CacheLogManager(pm: pm, logger: self).firstLog() {
                self?.sendLog(log: log)
            }
        }
    }

    private func sendLog(log: CDLog) {
        var req = URLRequest(url: URL(string: "http://10.56.34.61:8080/1m-http-server-test-chat")!)
        req.httpMethod = HTTPMethod.put.rawValue
        req.httpBody = try? JSONEncoder().encode(log.codable)
        req.allHTTPHeaderFields = ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"]
        let task = urlSession.dataTask(with: req) { [weak self] _, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                self?.deleteLogFromCache(log: log)
            }

            if let error = error {
                print("error to send log \(error)")
            }
        }
        task.resume()
    }

    private func deleteLogFromCache(log: CDLog) {
        if let pm = persistentManager {
            CacheLogManager(pm: pm, logger: self).delete([log.codable])
        }
    }

    private func addLogTocache(_ log: Log) {
        if let pm = persistentManager {
            CacheLogManager(pm: pm, logger: self).insert(models: [log])
        }
    }
}
