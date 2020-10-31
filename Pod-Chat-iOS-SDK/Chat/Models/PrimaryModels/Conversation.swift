//
//  Conversation.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Conversation {
    
    public var admin:                           Bool?
    public var canEditInfo:                     Bool?
    public var canSpam:                         Bool = false
    public var closedThread:                    Bool = false
    public var description:                     String?
    public var group:                           Bool?
    public var id:                              Int?
    public var image:                           String?
    public var joinDate:                        Int?
    public var lastMessage:                     String?
    public var lastParticipantImage:            String?
    public var lastParticipantName:             String?
    public var lastSeenMessageId:               Int?
    public var lastSeenMessageNanos:            UInt?
    public var lastSeenMessageTime:             UInt?
    public var mentioned:                       Bool?
    public var metadata:                        String?
    public var mute:                            Bool?
    public var participantCount:                Int?
    public var partner:                         Int?
    public var partnerLastDeliveredMessageId:   Int?
    public var partnerLastDeliveredMessageNanos:UInt?
    public var partnerLastDeliveredMessageTime: UInt?
    public var partnerLastSeenMessageId:        Int?
    public var partnerLastSeenMessageNanos:     UInt?
    public var partnerLastSeenMessageTime:      UInt?
    public var pin:                             Bool?
    public var time:                            UInt?
    public var title:                           String?
    public var type:                            Int?
    public var unreadCount:                     Int?
    public var uniqueName:                      String?
    public var userGroupHash:                   String?
    
    public var inviter:                         Participant?
    public var lastMessageVO:                   Message?
    public var participants:                    [Participant]?
    public var pinMessage:                      PinUnpinMessage?
    
    public init(messageContent: JSON) {
        self.admin                          = messageContent["admin"].bool
        self.canEditInfo                    = messageContent["canEditInfo"].bool
        self.canSpam                        = messageContent["canSpam"].bool ?? false
        self.closedThread                   = messageContent["closedThread"].bool ?? false
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
        self.mentioned                      = messageContent["mentioned"].bool
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
        self.pin                            = messageContent["pin"].bool ?? messageContent["pinned"].bool
        self.time                           = messageContent["time"].uInt
        self.title                          = messageContent["title"].string
        self.type                           = messageContent["type"].int
        self.unreadCount                    = messageContent["unreadCount"].int
        self.uniqueName                     = messageContent["uniqueName"].string
        self.userGroupHash                  = messageContent["userGroupHash"].string
        
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
        
        if (messageContent["pinMessageVO"] != JSON.null) {
            self.pinMessage = PinUnpinMessage(pinUnpinContent: messageContent["pinMessageVO"])
        }
        
    }
    
    public init(admin:          Bool?,
                canEditInfo:    Bool?,
                canSpam:        Bool?,
                closedThread:   Bool?,
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
                mentioned:              Bool?,
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
                pin:            Bool?,
                time:           UInt?,
                title:          String?,
                type:           Int?,
                unreadCount:    Int?,
                uniqueName:     String?,
                userGroupHash:  String?,
                inviter:        Participant?,
                lastMessageVO:  Message?,
                participants:   [Participant]?,
                pinMessage:     PinUnpinMessage?) {
        
        self.admin          = admin
        self.canEditInfo    = canEditInfo
        self.canSpam        = canSpam ?? false
        self.closedThread   = closedThread ?? false
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
        self.mentioned              = mentioned
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
        self.pin            = pin
        self.time           = time
        self.title          = title
        self.type           = type
        self.unreadCount    = unreadCount
        self.uniqueName     = uniqueName
        self.userGroupHash  = userGroupHash
        
        self.inviter        = inviter
        self.lastMessageVO  = lastMessageVO
        self.participants   = participants
        self.pinMessage     = pinMessage
    }
    
    public init(theConversation: Conversation) {
        
        self.admin          = theConversation.admin
        self.canEditInfo    = theConversation.canEditInfo
        self.canSpam        = theConversation.canSpam
        self.closedThread   = theConversation.closedThread
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
        self.mentioned              = theConversation.mentioned
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
        self.pin            = theConversation.pin
        self.time           = theConversation.time
        self.title          = theConversation.title
        self.type           = theConversation.type
        self.unreadCount    = theConversation.unreadCount
        self.uniqueName     = theConversation.uniqueName
        self.userGroupHash  = theConversation.userGroupHash
        
        self.inviter        = theConversation.inviter
        self.lastMessageVO  = theConversation.lastMessageVO
        self.participants   = theConversation.participants
        self.pinMessage     = theConversation.pinMessage
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
                            "canSpam":                      canSpam,
                            "closedThread":                 closedThread,
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
                            "mentioned":                    mentioned ?? NSNull(),
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
                            "pin":                          pin ?? NSNull(),
                            "time":                         time ?? NSNull(),
                            "title":                        title ?? NSNull(),
                            "type":                         type ?? NSNull(),
                            "unreadCount":                  unreadCount ?? NSNull(),
                            "uniqueName":                   uniqueName ?? NSNull(),
                            "userGroupHash":                userGroupHash ?? NSNull(),
                            "inviter":                      inviter?.formatToJSON() ?? NSNull(),
                            "lastMessageVO":                lastMessageVO?.formatToJSON() ?? NSNull(),
                            "participants":                 participantsJSON,
                            "pinMessage":                   pinMessage?.formatToJSON() ?? NSNull()]
//        if let lastMsgJSON = lastMessageVO {
//            result["lastMessageVO"] = lastMsgJSON.formatToJSON()
//        }
        
        return result
    }
    
}
