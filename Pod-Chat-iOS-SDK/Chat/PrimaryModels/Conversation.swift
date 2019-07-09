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

open class Conversation {
    
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
    
    public let admin:                           Bool?
    public let canEditInfo:                     Bool?
    public let canSpam:                         Bool?
    public let description:                     String?
    public let group:                           Bool?
    public let id:                              Int?
    public let image:                           String?
    public let joinDate:                        Int?
    public let lastMessage:                     String?
    public let lastParticipantImage:            String?
    public let lastParticipantName:             String?
    public let lastSeenMessageId:               Int?
    public let lastSeenMessageNanos:            UInt?
    public let lastSeenMessageTime:             UInt?
    public let metadata:                        String?
    public let mute:                            Bool?
    public let participantCount:                Int?
    public let partner:                         Int?
    public let partnerLastDeliveredMessageId:   Int?
    public let partnerLastDeliveredMessageNanos:UInt?
    public let partnerLastDeliveredMessageTime: UInt?
    public let partnerLastSeenMessageId:        Int?
    public let partnerLastSeenMessageNanos:     UInt?
    public let partnerLastSeenMessageTime:      UInt?
    public let time:                            UInt?
    public let title:                           String?
    public let type:                            Int?
    public let unreadCount:                     Int?
    
    public var inviter:                        Participant?
    public var lastMessageVO:                  Message?
    public var participants:                   [Participant]?
    
    public init(messageContent: JSON) {
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
        self.lastSeenMessageNanos           = messageContent["lastSeenMessageNanos"].uInt
        self.lastSeenMessageTime            = messageContent["lastSeenMessageTime"].uInt
        self.metadata                       = messageContent["metadata"].string
        self.mute                           = messageContent["mute"].bool
        self.participantCount               = messageContent["participantCount"].int
        self.partner                        = messageContent["partner"].int
        self.partnerLastDeliveredMessageId      = messageContent["partnerLastDeliveredMessageId"].int
        self.partnerLastDeliveredMessageNanos   = messageContent["partnerLastDeliveredMessageNanos"].uInt
        self.partnerLastDeliveredMessageTime    = messageContent["partnerLastDeliveredMessageTime"].uInt
        self.partnerLastSeenMessageId           = messageContent["partnerLastSeenMessageId"].int
        self.partnerLastSeenMessageNanos        = messageContent["partnerLastSeenMessageNanos"].uInt
        self.partnerLastSeenMessageTime         = messageContent["partnerLastSeenMessageTime"].uInt
        self.time                           = messageContent["time"].uInt
        self.title                          = messageContent["title"].string
        self.type                           = messageContent["type"].int
        self.unreadCount                    = messageContent["unreadCount"].int
        
        if (messageContent["inviter"] != JSON.null) {
            self.inviter = Participant(messageContent: messageContent["inviter"], threadId: id)
        }
        
        if let myParticipants = messageContent["participants"].array {
            var tempParticipants = [Participant]()
            for item in myParticipants {
                let participantData = Participant(messageContent: item, threadId: id)
                tempParticipants.append(participantData)
            }
            self.participants = tempParticipants
        }
        
        if (messageContent["lastMessageVO"] != JSON.null) {
            self.lastMessageVO = Message(threadId: id, pushMessageVO: messageContent["lastMessageVO"])
        }
        
    }
    
    public init(admin:          Bool?,
                canEditInfo:    Bool?,
                canSpam:        Bool?,
                description:    String?,
                group:          Bool?,
                id:             Int?,
                image:          String?,
                joinDate:       Int?,
                lastMessage:    String?,
                lastParticipantImage:   String?,
                lastParticipantName:    String?,
                lastSeenMessageId:      Int?,
                lastSeenMessageNanos:   UInt?,
                lastSeenMessageTime:    UInt?,
                metadata:               String?,
                mute:                   Bool?,
                participantCount:       Int?,
                partner:                Int?,
                partnerLastDeliveredMessageId:      Int?,
                partnerLastDeliveredMessageNanos:   UInt?,
                partnerLastDeliveredMessageTime:    UInt?,
                partnerLastSeenMessageId:       Int?,
                partnerLastSeenMessageNanos:    UInt?,
                partnerLastSeenMessageTime:     UInt?,
                time:           UInt?,
                title:          String?,
                type:           Int?,
                unreadCount:    Int?,
                inviter:        Participant?,
                lastMessageVO:  Message?,
                participants:   [Participant]?) {
        
        self.admin          = admin
        self.canEditInfo    = canEditInfo
        self.canSpam        = canSpam
        self.description    = description
        self.group          = group
        self.id             = id
        self.image          = image
        self.joinDate       = joinDate
        self.lastMessage    = lastMessage
        self.lastParticipantImage   = lastParticipantImage
        self.lastParticipantName    = lastParticipantName
        self.lastSeenMessageId      = lastSeenMessageId
        self.lastSeenMessageNanos   = lastSeenMessageNanos
        self.lastSeenMessageTime    = lastSeenMessageTime
        self.metadata               = metadata
        self.mute                   = mute
        self.participantCount       = participantCount
        self.partner                = partner
        self.partnerLastDeliveredMessageId      = partnerLastDeliveredMessageId
        self.partnerLastDeliveredMessageNanos   = partnerLastDeliveredMessageNanos
        self.partnerLastDeliveredMessageTime    = partnerLastDeliveredMessageTime
        self.partnerLastSeenMessageId       = partnerLastSeenMessageId
        self.partnerLastSeenMessageNanos    = partnerLastSeenMessageNanos
        self.partnerLastSeenMessageTime     = partnerLastSeenMessageTime
        self.time           = time
        self.title          = title
        self.type           = type
        self.unreadCount    = unreadCount
        
        self.inviter        = inviter
        self.lastMessageVO  = lastMessageVO
        self.participants   = participants
    }
    
    public init(theConversation: Conversation) {
        
        self.admin          = theConversation.admin
        self.canEditInfo    = theConversation.canEditInfo
        self.canSpam        = theConversation.canSpam
        self.description    = theConversation.description
        self.group          = theConversation.group
        self.id             = theConversation.id
        self.image          = theConversation.image
        self.joinDate       = theConversation.joinDate
        self.lastMessage    = theConversation.lastMessage
        self.lastParticipantImage   = theConversation.lastParticipantImage
        self.lastParticipantName    = theConversation.lastParticipantName
        self.lastSeenMessageId      = theConversation.lastSeenMessageId
        self.lastSeenMessageNanos   = theConversation.lastSeenMessageNanos
        self.lastSeenMessageTime    = theConversation.lastSeenMessageTime
        self.metadata               = theConversation.metadata
        self.mute                   = theConversation.mute
        self.participantCount       = theConversation.participantCount
        self.partner                = theConversation.partner
        self.partnerLastDeliveredMessageId      = theConversation.partnerLastDeliveredMessageId
        self.partnerLastDeliveredMessageNanos   = theConversation.partnerLastDeliveredMessageNanos
        self.partnerLastDeliveredMessageTime    = theConversation.partnerLastDeliveredMessageTime
        self.partnerLastSeenMessageId       = theConversation.partnerLastSeenMessageId
        self.partnerLastSeenMessageNanos    = theConversation.partnerLastSeenMessageNanos
        self.partnerLastSeenMessageTime     = theConversation.partnerLastSeenMessageTime
        self.time           = theConversation.time
        self.title          = theConversation.title
        self.type           = theConversation.type
        self.unreadCount    = theConversation.unreadCount
        
        self.inviter        = theConversation.inviter
        self.lastMessageVO  = theConversation.lastMessageVO
        self.participants   = theConversation.participants
    }
    
    
    public func formatDataToMakeConversation() -> Conversation {
        return self
    }
    
    public func formatToJSON() -> JSON {
        
        var participantsJSON: [JSON] = []
        if let participantArr = participants {
            for item in participantArr {
                let json = item.formatToJSON()
                participantsJSON.append(json)
            }
        }
        
        let result: JSON = ["admin":                        admin ?? NSNull(),
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
                            "lastSeenMessageNanos":         lastSeenMessageNanos ?? NSNull(),
                            "lastSeenMessageTime":          lastSeenMessageTime ?? NSNull(),
                            "metadata":                     metadata ?? NSNull(),
                            "mute":                         mute ?? NSNull(),
                            "participantCount":             participantCount ?? NSNull(),
                            "partner":                      partner ?? NSNull(),
                            "partnerLastDeliveredMessageId":    partnerLastDeliveredMessageId ?? NSNull(),
                            "partnerLastDeliveredMessageNanos": partnerLastDeliveredMessageNanos ?? NSNull(),
                            "partnerLastDeliveredMessageTime":  partnerLastDeliveredMessageTime ?? NSNull(),
                            "partnerLastSeenMessageId":     partnerLastSeenMessageId ?? NSNull(),
                            "partnerLastSeenMessageNanos":  partnerLastSeenMessageNanos ?? NSNull(),
                            "partnerLastSeenMessageTime":   partnerLastSeenMessageTime ?? NSNull(),
                            "time":                         time ?? NSNull(),
                            "title":                        title ?? NSNull(),
                            "type":                         type ?? NSNull(),
                            "unreadCount":                  unreadCount ?? NSNull(),
                            "inviter":                      inviter?.formatToJSON() ?? NSNull(),
                            "lastMessageVO":                lastMessageVO?.formatToJSON() ?? NSNull(),
                            "participants":                 participantsJSON]
//        if let lastMsgJSON = lastMessageVO {
//            result["lastMessageVO"] = lastMsgJSON.formatToJSON()
//        }
        
        return result
    }
    
}
