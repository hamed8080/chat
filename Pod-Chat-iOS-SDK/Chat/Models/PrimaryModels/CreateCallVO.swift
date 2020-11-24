//
//  CreateCallVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CreateCallVO {
    
    public var invitee:         [Invitee]?
    public var type:            Int?
    public var creatorId:       Int?
    public var creatorVO:       Participant?
    public var conversationVO:  Conversation?
    public var threadId:        Int?
    public var callId:          Int?
    public var isGroup:         Bool?
    
    public init(messageContent: JSON) {
        self.invitee    = [Invitee(messageContent: messageContent["invitee"])]
        self.type       = messageContent["type"].int
        self.creatorId  = messageContent["creatorId"].int
        
        if let creatorVOJSON = messageContent["creatorVO"] as JSON? {
            self.creatorVO = Participant(messageContent: creatorVOJSON, threadId: threadId)
        }
        
        if let conversationVOJSON = messageContent["conversationVO"] as JSON? {
            self.conversationVO = Conversation(messageContent: conversationVOJSON)
        }
        
        self.threadId   = messageContent["threadId"].int
        self.callId     = messageContent["callId"].int
        self.isGroup    = messageContent["isGroup"].bool
        
    }
    
    public init(invitee:        [Invitee],
                type:           Int,
                creatorId:      Int,
                creatorVO:      Participant,
                conversationVO: Conversation,
                threadId:       Int,
                callId:         Int,
                isGroup:        Bool) {
        self.invitee        = invitee
        self.type           = type
        self.creatorId      = creatorId
        self.creatorVO      = creatorVO
        self.conversationVO = conversationVO
        self.threadId       = threadId
        self.callId         = callId
        self.isGroup        = isGroup
    }
    
    public init(theCreateCallVO: CreateCallVO) {
        self.invitee        = theCreateCallVO.invitee
        self.type           = theCreateCallVO.type
        self.creatorId      = theCreateCallVO.creatorId
        self.creatorVO      = theCreateCallVO.creatorVO
        self.conversationVO = theCreateCallVO.conversationVO
        self.threadId       = theCreateCallVO.threadId
        self.callId         = theCreateCallVO.callId
        self.isGroup        = theCreateCallVO.isGroup
    }
    
    public func formatToJSON() -> JSON {
        var inviteeArr = [JSON]()
        for item in invitee ?? [] {
            inviteeArr.append(item.formatToJSON())
        }
        let result: JSON = ["invitee":          inviteeArr,
                            "type":             type ?? NSNull(),
                            "creatorId":        creatorId ?? NSNull(),
                            "creatorVO":        creatorVO?.formatToJSON() ?? NSNull(),
                            "conversationVO":   conversationVO?.formatToJSON() ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "callId":           callId ?? NSNull(),
                            "isGroup":          isGroup ?? NSNull()]
        return result
    }
    
}
