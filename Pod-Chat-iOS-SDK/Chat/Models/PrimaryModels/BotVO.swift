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
        if let thingJSON = messageContent["metadata"] as JSON? {
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
    
    public var id:      Int?    // its thing id of relevant thing of this bot in SSO
    public var name:    String? // bot name
    public var title:   String? // bot name
    public var type:    String? // it must be Bot
    public var owner:   Int?    // user of the bot owner
    public var creator: Int?
    public var bot:     Bool?
    
    
    public init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.name       = messageContent["name"].string
        self.title      = messageContent["title"].string
        self.type       = messageContent["type"].string
        self.owner      = messageContent["owner"].int
        self.creator    = messageContent["creator"].int
        self.bot        = messageContent["bot"].bool
    }
    
    public init(id:         Int?,
                name:       String?,
                title:      String?,
                type:       String?,
                owner:      Int?,
                creator:    Int?,
                bot:        Bool?) {
    
        self.id         = id
        self.name       = name
        self.title      = title
        self.type       = type
        self.owner      = owner
        self.creator    = creator
        self.bot        = bot
    }
    
    public init(theThing: ThingVO) {
        self.id         = theThing.id
        self.name       = theThing.name
        self.title      = theThing.title
        self.type       = theThing.type
        self.owner      = theThing.owner
        self.creator    = theThing.creator
        self.bot        = theThing.bot
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":       id ?? NSNull(),
                            "name":     name ?? NSNull(),
                            "title":    title ?? NSNull(),
                            "type":     type ?? NSNull(),
                            "owner":    owner ?? NSNull(),
                            "creator":  creator ?? NSNull(),
                            "bot":      bot ?? NSNull()]
        return result
    }
    
}


