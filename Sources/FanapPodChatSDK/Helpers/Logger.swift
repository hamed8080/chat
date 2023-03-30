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

/// There are two types of log.
/// 1- Logs that can store on the server.
/// 2- Logs on console or onLog method.
public final class Logger {
    private var sdkName: String { "CHAT_SDK-\(chat?.userInfo?.id ?? 0): " }
    weak var chat: ChatProtocol?
    private var urlSession: URLSessionProtocol
    private var config: ChatConfig? { chat?.config }
    var persistentManager: PersistentManager?
    private let timer: TimerProtocol

    init(timer: TimerProtocol = Timer(), urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
        self.timer = timer
        startSending()
    }

    func logJSON(title: String? = nil, jsonString: String? = nil, persist: Bool, type: LogEmitter) {
        log(message: "\(sdkName)\(title ?? "")\(jsonString != nil ? "\n" : "")  \(jsonString?.preetyJsonString() ?? "")", persist: persist, type: type)
    }

    func log(title: String? = nil, message: String? = nil, persist: Bool, type: LogEmitter) {
        log(message: "\(sdkName)\(title ?? "")\(message != nil ? "\n" : "") \(message ?? "")", persist: persist, type: type)
    }

    func log(_ request: URLRequest, _ decodeType: String, persist: Bool, type: LogEmitter) {
        var output = "\n"
        output += "Start Of Request============================================================================================\n"
        output += " REST Request With Method:\(request.httpMethod ?? "") - url:\(request.url?.absoluteString ?? "")\n"
        output += " With Headers:\(request.allHTTPHeaderFields?.debugDescription ?? "[]")\n"
        output += " With HttpBody:\(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")\n"
        output += " Expected DecodeType:\(decodeType)\n"
        output += "End  Of  Request============================================================================================\n"
        output += "\n"
        log(title: "CHAT_SDK:", message: output, persist: persist, type: type)
    }

    func log(_ data: Data?, _ response: URLResponse?, _ error: Error?, persist: Bool, type: LogEmitter) {
        var output = "\n"
        output += "Start Of Response============================================================================================\n"
        output += " REST Response For url:\(response?.url?.absoluteString ?? "")\n"
        output += " With Data Result in Body:\(String(data: data ?? Data(), encoding: .utf8) ?? "nil")\n"
        output += "End  Of  Response============================================================================================\n"
        output += "\n"
        log(title: "CHAT_SDK:", message: output, persist: persist, type: type)
        if let error = error {
            log(message: "\(error.localizedDescription) \n\(output)", persist: persist, level: .error, type: type)
        }
    }

    func log(message: String, persist: Bool, level: LogLevel = .verbose, type: LogEmitter) {
        let log = Log(
            message: message,
            config: config,
            deviceInfo: DeviceInfo.getDeviceInfo(),
            level: level,
            type: type
        )
        logOnConsole(log: log)
        if persist {
            persistOnServer(log: log)
        }
    }

    private func logOnConsole(log: Log) {
        if config?.isDebuggingLogEnabled == true {
            chat?.logDelegate?.onLog(log: log)
        }
    }

    private func persistOnServer(log: Log) {
        if config?.persistLogsOnServer == true {
            addLogToCache(log)
        }
    }

    private func startSending() {
        if config?.persistLogsOnServer ?? false == false { return }
        timer.scheduledTimer(interval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let bgTask = self.persistentManager?.newBgTask()
            if let bgTask = bgTask {
                CacheLogManager(context: bgTask, logger: self).firstLog { log in
                    if let log = log {
                        self.sendLog(log: log)
                    }
                }
            }
        }
    }

    private func sendLog(log: CDLog) {
        var req = URLRequest(url: URL(string: "http://10.56.34.61:8080/1m-http-server-test-chat")!)
        req.httpMethod = HTTPMethod.put.rawValue
        req.httpBody = try? JSONEncoder().encode(log.codable)
        req.allHTTPHeaderFields = ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"]
        let task = urlSession.dataTask(req) { [weak self] _, response, error in
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
        chat?.cache?.log.delete([log.codable])
    }

    private func addLogToCache(_ log: Log) {
        chat?.cache?.log.insert(models: [log])
    }
}
