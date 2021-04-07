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
    public var commandList: [String]    = []    // all commands that have been defined to this bot
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(messageContent: JSON) {
        self.botName    = messageContent["name"].string
        self.botUserId  = messageContent["botUserId"].int
        if let commandsJSON = messageContent["commandList"].arrayObject as? [String] {
            self.commandList    = commandsJSON
        }
    }
    
    public init(botName:    String?,
                botUserId:  Int?,
                commands:   [String]?) {
        self.botName    = botName
        self.botUserId  = botUserId
        if let theCommands = commands {
            self.commandList = theCommands
        }
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theBotInfoVO: BotInfoVO) {
        self.botName        = theBotInfoVO.botName
        self.botUserId      = theBotInfoVO.botUserId
        self.commandList    = theBotInfoVO.commandList
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["botName":      botName ?? NSNull(),
                            "botUserId":    botUserId ?? NSNull(),
                            "commandList":  commandList]
        return result
    }
    
}
