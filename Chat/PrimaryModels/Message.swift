//
//  Message.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Message        (formatDataToMakeMessage)
//#######################################################################################

open class Message {
    /*
     * + MessageVO      Message:
     *    - delivered:      Bool?
     *    - editable:       Bool?
     *    - edited:         Bool?
     *    - id:             Int?
     *    - message:        String?
     *    - metaData:       String?
     *    - ownerId:        Int?
     *    - previousId:     Int?
     *    - seen:           Bool?
     *    - threadId:       Int?
     *    - time:           Int?
     *    - uniqueId:       String?
     *    - conversation:   Conversation?
     *    - forwardInfo:    ForwardInfo?
     *    - participant:    Participant?
     *    - replyInfo:      ReplyInfo?
     */
    
    public let delivered:      Bool?
    public let editable:       Bool?
    public let edited:         Bool?
    public let id:             Int?
    public let message:        String?
    public let metaData:       String?
    public var ownerId:        Int?
    public let previousId:     Int?
    public let seen:           Bool?
    public var threadId:       Int?
    public let time:           Int?
    public let uniqueId:       String?
    
    public var conversation:   Conversation?
    public var forwardInfo:    ForwardInfo?
    public var participant:    Participant?
    public var replyInfo:      ReplyInfo?
    
    init(threadId: Int?, pushMessageVO: JSON) {
        if let theThreadId = threadId {
            self.threadId = theThreadId
        }
        
        self.delivered  = pushMessageVO["delivered"].bool
        self.editable   = pushMessageVO["editable"].bool
        self.edited     = pushMessageVO["edited"].bool
        self.id         = pushMessageVO["id"].int
        self.message    = pushMessageVO["message"].string
        self.metaData   = pushMessageVO["metaData"].string
        self.previousId = pushMessageVO["previousId"].int
        self.seen       = pushMessageVO["seen"].bool
        self.time       = pushMessageVO["time"].int
        self.uniqueId   = pushMessageVO["uniqueId"].string
        
        if (pushMessageVO["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: pushMessageVO["conversation"])
        }
        
        if (pushMessageVO["forwardInfo"] != JSON.null) {
            self.forwardInfo = ForwardInfo(messageContent: pushMessageVO["forwardInfo"])
        }
        
        if (pushMessageVO["participant"] != JSON.null) {
            let tempParticipant = Participant(messageContent: pushMessageVO["participant"])
            self.participant = tempParticipant
            let tempOwnerId = tempParticipant.formatToJSON()["id"].int
            self.ownerId = tempOwnerId
        }
        
        if (pushMessageVO["replyInfoVO"] != JSON.null) {
            self.replyInfo = ReplyInfo(messageContent: pushMessageVO["conversation"])
        }
        
        
        //        if let myParticipant = pushMessageVO["participant"].array {
        //            let tempParticipant = Participant(messageContent: myParticipant.first!)
        //            self.participant = tempParticipant
        //            let tempOwnerId = myParticipant.first!["id"].int
        //            self.ownerId = tempOwnerId
        //        }
        //        if let myConversation = pushMessageVO["conversation"].array {
        //            self.conversation = Conversation(messageContent: myConversation.first!)
        //        }
        //        if let myReplyInfo = pushMessageVO["replyInfoVO"].array {
        //            self.replyInfo = ReplyInfo(messageContent: myReplyInfo.first!)
        //        }
        //        if let myForwardInfo = pushMessageVO["forwardInfo"].array {
        //            self.forwardInfo = ForwardInfo(messageContent: myForwardInfo.first!)
        //        }
        
    }
    
    func formatDataToMakeMessage() -> Message {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["delivered":        delivered ?? NSNull(),
                            "editable":         editable ?? NSNull(),
                            "edited":           edited ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "message":          message ?? NSNull(),
                            "metaData":         metaData ?? NSNull(),
                            "ownerId":          ownerId ?? NSNull(),
                            "previousId":       previousId ?? NSNull(),
                            "seen":             seen ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "time":             time ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "forwardInfo":      forwardInfo?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull(),
                            "replyInfo":        replyInfo?.formatToJSON() ?? NSNull()]
        //        if let conversationJSON = conversation {
        //            result["conversation"] = conversationJSON.formatToJSON()
        //        }
        
        return result
    }
    
}
