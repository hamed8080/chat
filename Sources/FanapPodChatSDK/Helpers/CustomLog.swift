//
// CustomLog.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class Logger {
    private let sdkName = "CHAT_SDK: "
    private var isDebuggingLogEnabled: Bool
    private var isNotifLogEnabled: Bool = false

    init(isDebuggingLogEnabled: Bool) {
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        isNotifLogEnabled = Chat.sharedInstance.config?.enableNotificationLogObserver ?? false
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
}
