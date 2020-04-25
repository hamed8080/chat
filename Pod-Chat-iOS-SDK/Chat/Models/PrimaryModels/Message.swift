//
//  Message.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Message {
    
    public var deletable:   Bool?
    public var delivered:   Bool?
    public var editable:    Bool?
    public var edited:      Bool?
    public var id:          Int?
    public var mentioned:   Bool?
    public var message:     String?
    public var messageType: Int?
    public var metadata:    String?
    public var ownerId:     Int?
    public var pinned:      Bool?
    public var previousId:  Int?
    public var seen:        Bool?
    public var systemMetadata:  String?
    public var threadId:    Int?
    public var time:        UInt?
    public var timeNanos:   UInt?
//    public let timeNanos:   UInt?
    public var uniqueId:    String?
    
    public var conversation:    Conversation?
    public var forwardInfo:     ForwardInfo?
    public var participant:     Participant?
    public var replyInfo:       ReplyInfo?
    
    public init(threadId: Int?, pushMessageVO: JSON) {
        
        self.threadId       = threadId
        self.deletable      = pushMessageVO["deletable"].bool
        self.delivered      = pushMessageVO["delivered"].bool
        self.editable       = pushMessageVO["editable"].bool
        self.edited         = pushMessageVO["edited"].bool
        self.id             = pushMessageVO["id"].int
        self.mentioned      = pushMessageVO["mentioned"].bool
        self.message        = pushMessageVO["message"].string
        self.messageType    = pushMessageVO["messageType"].int
        self.metadata       = pushMessageVO["metadata"].string
        self.pinned         = pushMessageVO["pinned"].bool
        self.previousId     = pushMessageVO["previousId"].int
        self.seen           = pushMessageVO["seen"].bool
        self.systemMetadata = pushMessageVO["systemMetadata"].string
        self.time           = pushMessageVO["time"].uInt
        self.timeNanos      = pushMessageVO["timeNanos"].uInt
        self.uniqueId       = pushMessageVO["uniqueId"].string
        
//        let timeNano = pushMessageVO["timeNanos"].uIntValue
//        let timeTemp = pushMessageVO["time"].uIntValue
//        self.time = ((UInt(timeTemp / 1000)) * 1000000000 ) + timeNano
        
        if (pushMessageVO["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: pushMessageVO["conversation"])
        }
        
        if (pushMessageVO["forwardInfo"] != JSON.null) {
            self.forwardInfo = ForwardInfo(messageContent: pushMessageVO["forwardInfo"])
        }
        
        if (pushMessageVO["participant"] != JSON.null) {
            let tempParticipant = Participant(messageContent: pushMessageVO["participant"], threadId: threadId)
            self.participant = tempParticipant
            let tempOwnerId = tempParticipant.formatToJSON()["id"].int
            self.ownerId = tempOwnerId
        }
        
        if (pushMessageVO["replyInfoVO"] != JSON.null) {
            self.replyInfo = ReplyInfo(messageContent: pushMessageVO["replyInfoVO"])
        }
        
    }
    
    public init(threadId:       Int?,
                deletable:      Bool?,
                delivered:      Bool?,
                editable:       Bool?,
                edited:         Bool?,
                id:             Int?,
                mentioned:      Bool?,
                message:        String?,
                messageType:    Int?,
                metadata:       String?,
                ownerId:        Int?,
                pinned:         Bool?,
                previousId:     Int?,
                seen:           Bool?,
                systemMetadata: String?,
                time:           UInt?,
                timeNanos:      UInt?,
                uniqueId:       String?,
                conversation:   Conversation?,
                forwardInfo:    ForwardInfo?,
                participant:    Participant?,
                replyInfo:      ReplyInfo?) {
        
        self.threadId       = threadId
        self.deletable      = deletable
        self.delivered      = delivered
        self.editable       = editable
        self.edited         = edited
        self.id             = id
        self.mentioned      = mentioned
        self.message        = message
        self.messageType    = messageType
        self.metadata       = metadata
        self.ownerId        = participant?.id
        self.pinned         = pinned
        self.previousId     = previousId
        self.seen           = seen
        self.systemMetadata = systemMetadata
        self.time           = time
        self.timeNanos      = timeNanos
        self.uniqueId       = uniqueId
        self.conversation   = conversation
        self.forwardInfo    = forwardInfo
        self.participant    = participant
        self.replyInfo      = replyInfo
    }
    
    
    public init(theMessage: Message) {
        
        self.threadId       = theMessage.threadId
        self.deletable      = theMessage.deletable
        self.delivered      = theMessage.delivered
        self.editable       = theMessage.editable
        self.edited         = theMessage.edited
        self.id             = theMessage.id
        self.mentioned      = theMessage.mentioned
        self.message        = theMessage.message
        self.messageType    = theMessage.messageType
        self.metadata       = theMessage.metadata
        self.ownerId        = theMessage.participant?.id
        self.pinned         = theMessage.pinned
        self.previousId     = theMessage.previousId
        self.seen           = theMessage.seen
        self.systemMetadata = theMessage.systemMetadata
        self.time           = theMessage.time
        self.timeNanos      = theMessage.timeNanos
        self.uniqueId       = theMessage.uniqueId
        self.conversation   = theMessage.conversation
        self.forwardInfo    = theMessage.forwardInfo
        self.participant    = theMessage.participant
        self.replyInfo      = theMessage.replyInfo
    }
    
    
    func formatDataToMakeMessage() -> Message {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["deletable":        deletable ?? NSNull(),
                            "delivered":        delivered ?? NSNull(),
                            "editable":         editable ?? NSNull(),
                            "edited":           edited ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "mentioned":        mentioned ?? NSNull(),
                            "message":          message ?? NSNull(),
                            "messageType":      messageType ?? NSNull(),
                            "metadata":         metadata ?? NSNull(),
                            "ownerId":          ownerId ?? NSNull(),
                            "pinned":           pinned ?? NSNull(),
                            "previousId":       previousId ?? NSNull(),
                            "seen":             seen ?? NSNull(),
                            "systemMetadata":   systemMetadata ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "time":             time ?? NSNull(),
                            "timeNanos":        timeNanos ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "forwardInfo":      forwardInfo?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull(),
                            "replyInfo":        replyInfo?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
