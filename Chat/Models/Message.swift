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

class Message {
    /*
     * + MessageVO                       {object}
     *    - id                           {long}
     *    - threadId                     {long}
     *    - ownerId                      {long}
     *    - uniqueId                     {string}
     *    - previousId                   {long}
     *    - message                      {string}
     *    - edited                       {boolean}
     *    - editable                     {boolean}
     *    - delivered                    {boolean}
     *    - seen                         {boolean}
     *    - metadata                     {string}
     *    - time                         {long}
     *    - participant                  {object : ParticipantVO}
     *    - conversation                 {object : ConversationVO}
     *    - replyInfoVO                  {object : replyInfoVO}
     *    - forwardInfo                  {object : forwardInfoVO}
     
     */
    
    let id:             Int?
    let uniqueId:       String?
    let previousId:     Int?
    let message:        String?
    let edited:         Bool?
    let editable:       Bool?
    let delivered:      Bool?
    let seen:           Bool?
    let metaData:       String?
    let time:           Int?
    
    var threadId:       Int?
    var ownerId:        Int?
    var participant:    Participant?
    var conversation:   Conversation?
    var replyInfo:      ReplyInfo?
    var forwardInfo:    ForwardInfo?
    
    init(threadId: Int?, pushMessageVO: JSON) {
        if let theThreadId = threadId {
            self.threadId = theThreadId
        }
        
        self.id         = pushMessageVO["id"].int
        self.uniqueId   = pushMessageVO["uniqueId"].string
        self.previousId = pushMessageVO["previousId"].int
        self.message    = pushMessageVO["message"].string
        self.edited     = pushMessageVO["edited"].bool
        self.editable   = pushMessageVO["editable"].bool
        self.delivered  = pushMessageVO["delivered"].bool
        self.seen       = pushMessageVO["seen"].bool
        self.metaData   = pushMessageVO["metaData"].string
        self.time       = pushMessageVO["time"].int
        
        if let myParticipant = pushMessageVO["participant"].array {
            let tempParticipant = Participant(messageContent: myParticipant.first!)
            self.participant = tempParticipant
            let tempOwnerId = myParticipant.first!["id"].int
            self.ownerId = tempOwnerId
        }
        if let myConversation = pushMessageVO["conversation"].array {
            self.conversation = Conversation(messageContent: myConversation.first!)
        }
        if let myReplyInfo = pushMessageVO["replyInfoVO"].array {
            self.replyInfo = ReplyInfo(messageContent: myReplyInfo.first!)
        }
        if let myForwardInfo = pushMessageVO["forwardInfo"].array {
            self.forwardInfo = ForwardInfo(messageContent: myForwardInfo.first!)
        }
    }
    
    func formatDataToMakeMessage() -> Message {
        return self
    }
    
    func formatToJSON() -> JSON {
        var result: JSON = ["id":               id ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "previousId":       previousId ?? NSNull(),
                            "message":          message ?? NSNull(),
                            "edited":           edited ?? NSNull(),
                            "editable":         editable ?? NSNull(),
                            "delivered":        delivered ?? NSNull(),
                            "seen":             seen ?? NSNull(),
                            "metaData":         metaData ?? NSNull(),
                            "time":             time ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "ownerId":          ownerId ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull(),
                            //                            "conversation":     conversation?.formatToJSON() ?? NSNull(),
            "replyInfo":        replyInfo?.formatToJSON() ?? NSNull(),
            "forwardInfo":      forwardInfo?.formatToJSON() ?? NSNull()]
        if let conversationJSON = conversation {
            result["conversation"] = conversationJSON.formatToJSON()
        }
        
        return result
    }
    
}
