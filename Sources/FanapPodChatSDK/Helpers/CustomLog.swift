//
// CustomLog.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class Logger {
    private let sdkName = "CHAT_SDK: "
    private var isDebuggingLogEnabled: Bool
    private var isNotifLogEnabled: Bool = false

    init(config: ChatConfig?) {
        isDebuggingLogEnabled = config?.isDebuggingLogEnabled ?? false
        isNotifLogEnabled = config?.enableNotificationLogObserver ?? false
    }

    func log(title: String? = nil, jsonString: String? = nil, receive: Bool = true) {
        if isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }
            print("\n")
        }
        sendNotificationLogIfEnabled(title: title, jsonString: jsonString?.preetyJsonString(), receive: receive)
    }

    func log(title: String? = nil, message: String? = nil) {
        if isDebuggingLogEnabled {
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
        if isDebuggingLogEnabled {
            if let title = title {
                print(sdkName + title)
            }
            print("\n")
        }
    }

    func sendNotificationLogIfEnabled(title: String?, jsonString: String?, receive: Bool) {
        if isNotifLogEnabled, let jsonString = jsonString {
            let title = "\(sdkName)\(title ?? "")\n"
            let jsonWithTitle = title + jsonString
            NotificationCenter.default.post(name: Notification.Name("log"), object: LogResult(json: jsonWithTitle, receive: receive))
        }
    }

    func restRequest(_ request: URLRequest, _ decodeType: String) {
        if isDebuggingLogEnabled == true {
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

    func restResponse(_ data: Data?, _ response: URLResponse?, _: Error?) {
        if isDebuggingLogEnabled == true {
            var output = "\n"
            output += "Start Of Response============================================================================================\n"
            output += " REST Response For url:\(response?.url?.absoluteString ?? "")\n"
            output += " With Data Result in Body:\(String(data: data ?? Data(), encoding: .utf8) ?? "nil")\n"
            output += "End  Of  Response============================================================================================\n"
            output += "\n"
            log(title: "CHAT_SDK:", message: output)
        }
    }
}
