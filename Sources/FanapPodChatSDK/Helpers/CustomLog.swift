//
//  CustomLog.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/15/21.
//

import Foundation

class Logger{
    private let SDK_NAME = "CHAT_SDK: "
    private var isDebuggingLogEnabled:Bool
    private var isNotifLogEnabled:Bool = false
    
    init(isDebuggingLogEnabled:Bool){
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
        self.isNotifLogEnabled = Chat.sharedInstance.config?.enableNotificationLogObserver ?? false
    }
    
    func log(title:String? = nil ,jsonString:String? = nil, receive:Bool = true){
        if  isDebuggingLogEnabled{
            if let title = title{
                print(SDK_NAME + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }
            print("\n")
        }
        sendNotificationLogIfEnabled(title:title, jsonString: jsonString?.preetyJsonString(), receive: receive)
    }
    
    func log(title:String? = nil ,message:String? = nil){
        if  isDebuggingLogEnabled{
            if let title = title{
                print(SDK_NAME + title)
            }
            if let message = message {
                print(message)
            }
            print("\n")
        }
    }
    
    func log(title:String? = nil){
        if  isDebuggingLogEnabled{
            if let title = title{
                print(SDK_NAME + title)
            }
            print("\n")
        }
    }
    
    func sendNotificationLogIfEnabled(title:String?, jsonString:String?,receive:Bool){
        if isNotifLogEnabled, let jsonString = jsonString{
            let title = "\(SDK_NAME)\(title ?? "")\n"
            let jsonWithTitle = title + jsonString
            NotificationCenter.default.post(name: Notification.Name("log"),object: LogResult(json: jsonWithTitle, receive: receive))
        }
    }
}

