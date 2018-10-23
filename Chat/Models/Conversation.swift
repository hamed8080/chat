//
//  Conversation.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Conversation        (formatDataToMakeConversation)
//#######################################################################################

class Conversation {
    
    /*
     * + Conversation                     {object}
     *    - id                            {long}
     *    - joinDate                      {long}
     *    - title                         {string}
     *    - time                          {long}
     *    - lastMessage                   {string}
     *    - lastParticipantName           {string}
     *    - group                         {boolean}
     *    - partner                       {long}
     *    - lastParticipantImage          {string}
     *    - image                         {string}
     *    - description                   {string}
     *    - unreadCount                   {long}
     *    - lastSeenMessageId             {long}
     *    - partnerLastSeenMessageId      {long}
     *    - partnerLastDeliveredMessageId {long}
     *    - type                          {int}
     *    - metadata                      {string}
     *    - mute                          {boolean}
     *    - participantCount              {long}
     *    - canEditInfo                   {boolean}
     *    - canSpam                       {boolean}
     
     *    - inviter                       {object : ParticipantVO}
     *    - participants                  {list : ParticipantVO}
     *    - lastMessageVO                 {object : ChatMessageVO}
     */
    
    let id:                             Int?
    let joinDate:                       Int?
    let title:                          String?
    let time:                           Int?
    let lastMessage:                    String?
    let lastParticipantName:            String?
    let group:                          Bool?
    let partner:                        Int?
    let lastParticipantImage:           String?
    let image:                          String?
    let description:                    String?
    let unreadCount:                    Int?
    let lastSeenMessageId:              Int?
    let partnerLastSeenMessageId:       Int?
    let partnerLastDeliveredMessageId:  Int?
    let type:                           Int?
    let metadata:                       String?
    let mute:                           Bool?
    let participantCount:               Int?
    let canEditInfo:                    Bool?
    let canSpam:                        Bool?
    
    var inviter:                        Invitee?
    var participants:                   [Participant]?
    var lastMessageVO:                  Message?
    
    init(messageContent: JSON) {
        self.id                             = messageContent["id"].int
        self.joinDate                       = messageContent["joinDate"].int
        self.title                          = messageContent["title"].string
        self.time                           = messageContent["time"].int
        self.lastMessage                    = messageContent["lastMessage"].string
        self.lastParticipantName            = messageContent["lastParticipantName"].string
        self.group                          = messageContent["group"].bool
        self.partner                        = messageContent["partner"].int
        self.lastParticipantImage           = messageContent["lastParticipantImage"].string
        self.image                          = messageContent["image"].string
        self.description                    = messageContent["description"].string
        self.unreadCount                    = messageContent["unreadCount"].int
        self.lastSeenMessageId              = messageContent["lastSeenMessageId"].int
        self.partnerLastSeenMessageId       = messageContent["partnerLastSeenMessageId"].int
        self.partnerLastDeliveredMessageId  = messageContent["partnerLastDeliveredMessageId"].int
        self.type                           = messageContent["type"].int
        self.metadata                       = messageContent["metadata"].string
        self.mute                           = messageContent["mute"].bool
        self.participantCount               = messageContent["participantCount"].int
        self.canEditInfo                    = messageContent["canEditInfo"].bool
        self.canSpam                        = messageContent["canSpam"].bool
        
        if let myInviter = messageContent["inviter"].array {
            let temp = Invitee(messageContent: myInviter.first!)
            self.inviter = temp
        }
        if let myParticipants = messageContent["participants"].array {
            var tempParticipants = [Participant]()
            for item in myParticipants {
                let participantData = Participant(messageContent: item)
                tempParticipants.append(participantData)
            }
            self.participants = tempParticipants
        }
        if let myLastMessageVO = messageContent["lastMessageVO"].array {
            self.lastMessageVO = Message(threadId: nil, pushMessageVO: myLastMessageVO.first!)
        }
    }
    
    func formatDataToMakeConversation() -> Conversation {
        return self
    }
    
    func formatToJSON() -> JSON {
        
        var participantsJSON: [JSON] = []
        if let participantArr = participants {
            for item in participantArr {
                let json = item.formatToJSON()
                participantsJSON.append(json)
            }
        }
        
        var result: JSON = ["id":                           id ?? NSNull(),
                            "joinDate":                     joinDate ?? NSNull(),
                            "title":                        title ?? NSNull(),
                            "time":                         time ?? NSNull(),
                            "lastMessage":                  lastMessage ?? NSNull(),
                            "lastParticipantName":          lastParticipantName ?? NSNull(),
                            "group":                        group ?? NSNull(),
                            "partner":                      partner ?? NSNull(),
                            "lastParticipantImage":         lastParticipantImage ?? NSNull(),
                            "image":                        image ?? NSNull(),
                            "description":                  description ?? NSNull(),
                            "unreadCount":                  unreadCount ?? NSNull(),
                            "lastSeenMessageId":            lastSeenMessageId ?? NSNull(),
                            "partnerLastSeenMessageId":     partnerLastSeenMessageId ?? NSNull(),
                            "partnerLastDeliveredMessageId": partnerLastDeliveredMessageId ?? NSNull(),
                            "type":                         type ?? NSNull(),
                            "metadata":                     metadata ?? NSNull(),
                            "mute":                         mute ?? NSNull(),
                            "participantCount":             participantCount ?? NSNull(),
                            "canEditInfo":                  canEditInfo ?? NSNull(),
                            "canSpam":                      canSpam ?? NSNull(),
                            "inviter":                      inviter?.formatToJSON() ?? NSNull(),
                            "participants":                 participantsJSON,
                            "lastMessageVO":                lastMessageVO?.formatToJSON() ?? NSNull()]
        if let lastMsgJSON = lastMessageVO {
            result["lastMessageVO"] = lastMsgJSON.formatToJSON()
        }
        
        return result
    }
    
}
