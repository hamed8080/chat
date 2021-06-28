//
//  AddBotCommandRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class AddBotCommandRequest: RequestModelDelegates {
    
    public let botName:         String
    public var commandList:     [String] = []
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(botName:        String,
                commandList:    [String],
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.botName    = botName
        for command in commandList {
            if (command.first == "/") {
                self.commandList.append(command)
            } else {
                self.commandList.append("/\(command)")
            }
        }
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["botName"]      = JSON(botName)
        content["commandList"]  = JSON(commandList)
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}
