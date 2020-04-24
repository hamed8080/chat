//
//  BotInfoVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class BotInfoVO {
    
    public var botName:     String?
    public var botUserId:   Int?                // id of user equivalent to bot
    public var commands:    [String]    = []    // all commands that have been defined to this bot
    
    public init(messageContent: JSON) {
        self.botName    = messageContent["name"].string
        self.botUserId  = messageContent["botUserId"].int
        if let commandsJSON = messageContent["command"].arrayObject as? [String] {
            self.commands   = commandsJSON
        }
    }
    
    public init(botName:    String?,
                botUserId:  Int?,
                commands:   [String]?) {
        self.botName    = botName
        self.botUserId  = botUserId
        if let theCommands = commands {
            self.commands = theCommands
        }
    }
    
    public init(theBotInfoVO: BotInfoVO) {
        self.botName    = theBotInfoVO.botName
        self.botUserId  = theBotInfoVO.botUserId
        self.commands   = theBotInfoVO.commands
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["botName":      botName ?? NSNull(),
                            "botUserId":    botUserId ?? NSNull(),
                            "commands":     commands]
        return result
    }
    
}
