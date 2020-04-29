//
//  BotVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class BotVO {
    
    public var apiToken:    String?
    public var thingVO:     ThingVO?
    
    public init(messageContent: JSON) {
        self.apiToken        = messageContent["apiToken"].string
        if let thingJSON = messageContent["thingVO"] as JSON? {
            self.thingVO    = ThingVO(messageContent: thingJSON)
        } else {
            self.thingVO    = nil
        }
    }
    
    public init(apiToken:   String?,
                thingVO:    ThingVO?) {
        self.apiToken   = apiToken
        self.thingVO    = thingVO
    }
    
    public init(theBotVO: BotVO) {
        self.apiToken   = theBotVO.apiToken
        self.thingVO    = theBotVO.thingVO
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["apiToken": apiToken ?? NSNull(),
                            "thingVO":  thingVO?.formatToJSON() ?? NSNull()]
        return result
    }
    
}


open class ThingVO {
    
    public var id:                  Int?    // its thing id of relevant thing of this bot in SSO
    public var name:                String? // bot name
    public var title:               String? // bot name
    public var type:                String? // it must be Bot
//    public var owner:               Int?    // user of the bot owner
//    public var creator:             Int?
    public var bot:                 Bool?
    public var active:              Bool?
    public var chatSendEnable:      Bool?
    public var chatReceiveEnable:   Bool?
    public var owner:               Participant?
    public var creator:             Participant?
    
    public init(messageContent: JSON) {
        self.id                 = messageContent["id"].int
        self.name               = messageContent["name"].string
        self.title              = messageContent["title"].string
        self.type               = messageContent["type"].string
//        self.owner              = messageContent["owner"].int
//        self.creator            = messageContent["creator"].int
        self.bot                = messageContent["bot"].bool
        self.active             = messageContent["active"].bool
        self.chatSendEnable     = messageContent["chatSendEnable"].bool
        self.chatReceiveEnable  = messageContent["chatReceiveEnable"].bool
        
        if let theOwner = messageContent["owner"] as JSON? {
            self.owner  = Participant(messageContent: theOwner, threadId: nil)
        } else {
            self.owner  = nil
        }
        if let theCreator = messageContent["creator"] as JSON? {
            self.creator  = Participant(messageContent: theCreator, threadId: nil)
        } else {
            self.creator  = nil
        }
    }
    
    public init(id:                 Int?,
                name:               String?,
                title:              String?,
                type:               String?,
                owner:              Participant?,
                creator:            Participant?,
                bot:                Bool?,
                active:             Bool?,
                chatSendEnable:     Bool?,
                chatReceiveEnable:  Bool?) {
    
        self.id                 = id
        self.name               = name
        self.title              = title
        self.type               = type
        self.owner              = owner
        self.creator            = creator
        self.bot                = bot
        self.active             = active
        self.chatSendEnable     = chatSendEnable
        self.chatReceiveEnable  = chatReceiveEnable
    }
    
    public init(theThing: ThingVO) {
        self.id                 = theThing.id
        self.name               = theThing.name
        self.title              = theThing.title
        self.type               = theThing.type
        self.owner              = theThing.owner
        self.creator            = theThing.creator
        self.bot                = theThing.bot
        self.active             = theThing.active
        self.chatSendEnable     = theThing.chatSendEnable
        self.chatReceiveEnable  = theThing.chatReceiveEnable
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":                   id ?? NSNull(),
                            "name":                 name ?? NSNull(),
                            "title":                title ?? NSNull(),
                            "type":                 type ?? NSNull(),
                            "owner":                owner?.formatToJSON() ?? NSNull(),
                            "creator":              creator?.formatToJSON() ?? NSNull(),
                            "bot":                  bot ?? NSNull(),
                            "active":               active ?? NSNull(),
                            "chatSendEnable":       chatSendEnable ?? NSNull(),
                            "chatReceiveEnable":    chatReceiveEnable ?? NSNull()]
        return result
    }
    
}


