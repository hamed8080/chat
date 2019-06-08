//
//  CMConversation+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMConversation: NSManagedObject {
    
    public func convertCMConversationToConversationObject() -> Conversation {
        var admin:                          Bool?
        var canEditInfo:                    Bool?
        var canSpam:                        Bool?
        var group:                          Bool?
        var id:                             Int?
        var joinDate:                       Int?
        //        var lastParticipantImage:           String?
        //        var lastParticipantName:            String?
        var lastSeenMessageId:              Int?
        var lastSeenMessageNanos:           UInt?
        var lastSeenMessageTime:            UInt?
        var mute:                           Bool?
        var participantCount:               Int?
        var partner:                        Int?
        var partnerLastDeliveredMessageId:      Int?
        var partnerLastDeliveredMessageNanos:   UInt?
        var partnerLastDeliveredMessageTime:    UInt?
        var partnerLastSeenMessageId:       Int?
        var partnerLastSeenMessageNanos:    UInt?
        var partnerLastSeenMessageTime:     UInt?
        var time:                           UInt?
        var type:                           Int?
        var unreadCount:                    Int?
        var participants                    = [Participant]()
        
        func createVariables() {
            if let admin2 = self.admin as? Bool {
                admin = admin2
            }
            if let canEditInfo2 = self.canEditInfo as? Bool {
                canEditInfo = canEditInfo2
            }
            if let canSpam2 = self.canSpam as? Bool {
                canSpam = canSpam2
            }
            if let group2 = self.group as? Bool {
                group = group2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let joinDate2 = self.joinDate as? Int {
                joinDate = joinDate2
            }
            if let lastSeenMessageId2 = self.lastSeenMessageId as? Int {
                lastSeenMessageId = lastSeenMessageId2
            }
            if let lastSeenMessageNanos2 = self.lastSeenMessageNanos as? UInt {
                lastSeenMessageNanos = lastSeenMessageNanos2
            }
            if let lastSeenMessageTime2 = self.lastSeenMessageTime as? UInt {
                lastSeenMessageTime = lastSeenMessageTime2
            }
            if let mute2 = self.mute as? Bool {
                mute = mute2
            }
            if let participantCount2 = self.participantCount as? Int {
                participantCount = participantCount2
            }
            if let partner2 = self.partner as? Int {
                partner = partner2
            }
            if let partnerLastDeliveredMessageId2 = self.partnerLastDeliveredMessageId as? Int {
                partnerLastDeliveredMessageId = partnerLastDeliveredMessageId2
            }
            if let partnerLastDeliveredMessageNanos2 = self.partnerLastDeliveredMessageNanos as? UInt {
                partnerLastDeliveredMessageNanos = partnerLastDeliveredMessageNanos2
            }
            if let partnerLastDeliveredMessageTime2 = self.partnerLastDeliveredMessageTime as? UInt {
                partnerLastDeliveredMessageTime = partnerLastDeliveredMessageTime2
            }
            if let partnerLastSeenMessageId2 = self.partnerLastSeenMessageId as? Int {
                partnerLastSeenMessageId = partnerLastSeenMessageId2
            }
            if let partnerLastSeenMessageNanos2 = self.partnerLastSeenMessageNanos as? UInt {
                partnerLastSeenMessageNanos = partnerLastSeenMessageNanos2
            }
            if let partnerLastSeenMessageTime2 = self.partnerLastSeenMessageTime as? UInt {
                partnerLastSeenMessageTime = partnerLastSeenMessageTime2
            }
            if let time2 = self.time as? UInt {
                time = time2
            }
            if let type2 = self.type as? Int {
                type = type2
            }
            if let unreadCount2 = self.unreadCount as? Int {
                unreadCount = unreadCount2
            }
            
            
            if let participantArr = self.participants {
                for item in participantArr {
                    participants.append(item.convertCMParticipantToParticipantObject())
                }
            }
        }
        
        
        
        func createMessageModel() -> Conversation {
            let conversationModel = Conversation(admin:                 admin,
                                                 canEditInfo:           canEditInfo,
                                                 canSpam:               canSpam,
                                                 description:           self.descriptions,
                                                 group:                 group,
                                                 id:                    id,
                                                 image:                 self.image,
                                                 joinDate:              joinDate,
                                                 lastMessage:           self.lastMessage,
                                                 lastParticipantImage:  lastParticipantImage,
                                                 lastParticipantName:   lastParticipantName,
                                                 lastSeenMessageId:     lastSeenMessageId,
                                                 lastSeenMessageNanos:  lastSeenMessageNanos,
                                                 lastSeenMessageTime:   lastSeenMessageTime,
                                                 metadata:              self.metadata,
                                                 mute:                  mute,
                                                 participantCount:      participantCount,
                                                 partner:               partner,
                                                 partnerLastDeliveredMessageId:     partnerLastDeliveredMessageId,
                                                 partnerLastDeliveredMessageNanos:  partnerLastDeliveredMessageNanos,
                                                 partnerLastDeliveredMessageTime:   partnerLastDeliveredMessageTime,
                                                 partnerLastSeenMessageId:      partnerLastSeenMessageId,
                                                 partnerLastSeenMessageNanos:   partnerLastSeenMessageNanos,
                                                 partnerLastSeenMessageTime:    partnerLastSeenMessageTime,
                                                 time:                  time,
                                                 title:                 self.title,
                                                 type:                  type,
                                                 unreadCount:           unreadCount,
                                                 inviter:               self.inviter?.convertCMParticipantToParticipantObject(),
                                                 lastMessageVO:         self.lastMessageVO?.convertCMMessageToMessageObject(),
                                                 participants:          participants)
            
            return conversationModel
        }
        
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
}
