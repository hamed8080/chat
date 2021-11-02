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
    
    init(isDebuggingLogEnabled:Bool){
        self.isDebuggingLogEnabled = isDebuggingLogEnabled
    }
    
    func log(title:String? = nil ,jsonString:String? = nil){
        if  isDebuggingLogEnabled{
            if let title = title{
                print(SDK_NAME + title)
            }
            if let jsonString = jsonString {
                print("\(jsonString.preetyJsonString())")
            }
            print("\n")
        }
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
}

