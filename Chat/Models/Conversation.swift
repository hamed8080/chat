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
     * + Conversation       Conversation:
     *    - admin:                          Bool?
     *    - canEditInfo:                    Bool?
     *    - canSpam:                        Bool?
     *    - description:                    String?
     *    - group:                          Bool?
     *    - id:                             Int?
     *    - image:                          String?
     *    - joinDate:                       Int?
     *    - lastMessage:                    String?
     *    - lastParticipantImage:           String?
     *    - lastParticipantName:            String?
     *    - lastSeenMessageId:              Int?
     *    - metadata:                       String?
     *    - mute:                           Bool?
     *    - participantCount:               Int?
     *    - partner:                        Int?
     *    - partnerLastDeliveredMessageId:  Int?
     *    - partnerLastSeenMessageId:       Int?
     *    - title:                          String?
     *    - time:                           Int?
     *    - type:                           Int?
     *    - unreadCount:                    Int?
     
     *    - inviter:                        Participant?
     *    - lastMessageVO:                  Message?
     *    - participants:                   [Participant]?
     */
    
    let admin:                          Bool?
    let canEditInfo:                    Bool?
    let canSpam:                        Bool?
    let description:                    String?
    let group:                          Bool?
    let id:                             Int?
    let image:                          String?
    let joinDate:                       Int?
    let lastMessage:                    String?
    let lastParticipantImage:           String?
    let lastParticipantName:            String?
    let lastSeenMessageId:              Int?
    let metadata:                       String?
    let mute:                           Bool?
    let participantCount:               Int?
    let partner:                        Int?
    let partnerLastDeliveredMessageId:  Int?
    let partnerLastSeenMessageId:       Int?
    let title:                          String?
    let time:                           Int?
    let type:                           Int?
    let unreadCount:                    Int?
    
    var inviter:                        Participant?
    var lastMessageVO:                  Message?
    var participants:                   [Participant]?
    
    init(messageContent: JSON) {
        self.admin                          = messageContent["admin"].bool
        self.canEditInfo                    = messageContent["canEditInfo"].bool
        self.canSpam                        = messageContent["canSpam"].bool
        self.description                    = messageContent["description"].string
        self.group                          = messageContent["group"].bool
        self.id                             = messageContent["id"].int
        self.image                          = messageContent["image"].string
        self.joinDate                       = messageContent["joinDate"].int
        self.lastMessage                    = messageContent["lastMessage"].string
        self.lastParticipantImage           = messageContent["lastParticipantImage"].string
        self.lastParticipantName            = messageContent["lastParticipantName"].string
        self.lastSeenMessageId              = messageContent["lastSeenMessageId"].int
        self.metadata                       = messageContent["metadata"].string
        self.mute                           = messageContent["mute"].bool
        self.participantCount               = messageContent["participantCount"].int
        self.partner                        = messageContent["partner"].int
        self.partnerLastDeliveredMessageId  = messageContent["partnerLastDeliveredMessageId"].int
        self.partnerLastSeenMessageId       = messageContent["partnerLastSeenMessageId"].int
        self.time                           = messageContent["time"].int
        self.title                          = messageContent["title"].string
        self.type                           = messageContent["type"].int
        self.unreadCount                    = messageContent["unreadCount"].int
        
        if (messageContent["inviter"] != JSON.null) {
            self.inviter = Participant(messageContent: messageContent["inviter"])
        }
        
        if let myParticipants = messageContent["participants"].array {
            var tempParticipants = [Participant]()
            for item in myParticipants {
                let participantData = Participant(messageContent: item)
                tempParticipants.append(participantData)
            }
            self.participants = tempParticipants
        }
        
        if (messageContent["lastMessageVO"] != JSON.null) {
            self.lastMessageVO = Message(threadId: nil, pushMessageVO: messageContent["lastMessageVO"])
        }
        //        if let myLastMessageVO = messageContent["lastMessageVO"].array {
        //            self.lastMessageVO = Message(threadId: nil, pushMessageVO: myLastMessageVO.first!)
        //        }
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
        
        var result: JSON = ["admin":                        admin ?? NSNull(),
                            "canEditInfo":                  canEditInfo ?? NSNull(),
                            "canSpam":                      canSpam ?? NSNull(),
                            "description":                  description ?? NSNull(),
                            "group":                        group ?? NSNull(),
                            "id":                           id ?? NSNull(),
                            "image":                        image ?? NSNull(),
                            "joinDate":                     joinDate ?? NSNull(),
                            "lastMessage":                  lastMessage ?? NSNull(),
                            "lastParticipantImage":         lastParticipantImage ?? NSNull(),
                            "lastParticipantName":          lastParticipantName ?? NSNull(),
                            "lastSeenMessageId":            lastSeenMessageId ?? NSNull(),
                            "metadata":                     metadata ?? NSNull(),
                            "mute":                         mute ?? NSNull(),
                            "participantCount":             participantCount ?? NSNull(),
                            "partner":                      partner ?? NSNull(),
                            "partnerLastDeliveredMessageId":partnerLastDeliveredMessageId ?? NSNull(),
                            "partnerLastSeenMessageId":     partnerLastSeenMessageId ?? NSNull(),
                            "time":                         time ?? NSNull(),
                            "title":                        title ?? NSNull(),
                            "type":                         type ?? NSNull(),
                            "unreadCount":                  unreadCount ?? NSNull(),
                            "inviter":                      inviter?.formatToJSON() ?? NSNull(),
                            "lastMessageVO":                lastMessageVO?.formatToJSON() ?? NSNull(),
                            "participants":                 participantsJSON]
        if let lastMsgJSON = lastMessageVO {
            result["lastMessageVO"] = lastMsgJSON.formatToJSON()
        }
        
        return result
    }
    
}
