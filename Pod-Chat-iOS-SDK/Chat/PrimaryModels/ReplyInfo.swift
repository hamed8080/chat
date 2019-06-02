//
//  ReplyInfo.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      ReplyInfo        (formatDataToMakeReplyInfo)
//#######################################################################################

open class ReplyInfo {
    /*
     * + replyInfoVO        ReplyInfo:
     *  - deleted:             Bool?            // Delete state of Replied Message
     *  - repliedToMessageId:  Int?             // Id of Replied Message
     *  - message:             String?          // Content of Replied Message
     *  - messageType:         Int?             // Type of Replied Message
     *  - metadata:            String?          // metadata of Replied Message
     *  - systemMetadata:      String?          // systemMetadata of Replied Message
     *  - participant          Participant?     // Sender of Replied Message
     *  - repliedToMessage     String?
     *  - repliedToMessageId   Int?
     */
    
    
    public let deleted:             Bool?
    public let repliedToMessageId:  Int?
    public let message:             String?
    public let messageType:         Int?
    public let metadata:            String?
    public let systemMetadata:      String?
//    public let timeNanos:           UInt?
    public let time:                UInt?
    
    public let participant:        Participant?
    //    public let repliedToMessage:    String?
    
    public init(messageContent: JSON) {
        
        self.deleted            = messageContent["deleted"].bool
        self.message            = messageContent["message"].string
        self.messageType        = messageContent["messageType"].int
        self.metadata           = messageContent["metadata"].string
        self.repliedToMessageId = messageContent["repliedToMessageId"].int
        self.systemMetadata     = messageContent["systemMetadata"].string
        
        let timeNano = messageContent["repliedToMessageNanos"].uIntValue
        let timeTemp = messageContent["repliedToMessageTime"].uIntValue
        self.time = ((UInt(timeTemp / 1000)) * 1000000000 ) + timeNano
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"], threadId: nil)
        } else {
            self.participant = nil
        }
        
    }
    
    public init(deleted:            Bool?,
                repliedToMessageId: Int?,
                message:            String?,
                messageType:        Int?,
                metadata:           String?,
                systemMetadata:     String?,
                time:               UInt?,
                participant:        Participant?) {
        
        self.deleted            = deleted
        self.repliedToMessageId = repliedToMessageId
        self.message            = message
        self.messageType        = messageType
        self.metadata           = metadata
        self.systemMetadata     = systemMetadata
        self.time               = time
        self.participant        = participant
        
    }
    
    public init(theReplyInfo: ReplyInfo) {
        
        self.deleted            = theReplyInfo.deleted
        self.repliedToMessageId = theReplyInfo.repliedToMessageId
        self.message            = theReplyInfo.message
        self.messageType        = theReplyInfo.messageType
        self.metadata           = theReplyInfo.metadata
        self.systemMetadata     = theReplyInfo.systemMetadata
        self.time               = theReplyInfo.time
        self.participant        = theReplyInfo.participant
    }
    
    
    public func formatDataToMakeReplyInfo() -> ReplyInfo {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["participant":          participant?.formatToJSON() ?? NSNull(),
                            "deleted":              deleted ?? NSNull(),
                            "message":              message ?? NSNull(),
                            "messageType":          messageType ?? NSNull(),
                            "metadata":             metadata ?? NSNull(),
                            "repliedToMessageId":   repliedToMessageId ?? NSNull(),
                            "systemMetadata":       systemMetadata ?? NSNull(),
                            "time":                 time ?? NSNull()]
        return result
    }
    
}
