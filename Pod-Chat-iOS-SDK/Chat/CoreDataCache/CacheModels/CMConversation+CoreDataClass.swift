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
    
    public func convertCMObjectToObject(showInviter:        Bool,
                                        showLastMessageVO:  Bool,
                                        showParticipants:   Bool,
                                        showPinMessage:     Bool) -> Conversation {
        var admin:                          Bool?
        var canEditInfo:                    Bool?
        var canSpam:                        Bool?
        var closedThread:                   Bool?
        var group:                          Bool?
        var id:                             Int?
        var joinDate:                       Int?
        var lastSeenMessageId:              Int?
        var lastSeenMessageNanos:           UInt?
        var lastSeenMessageTime:            UInt?
        var mentioned:                      Bool?
        var mute:                           Bool?
        var participantCount:               Int?
        var partner:                        Int?
        var partnerLastDeliveredMessageId:      Int?
        var partnerLastDeliveredMessageNanos:   UInt?
        var partnerLastDeliveredMessageTime:    UInt?
        var partnerLastSeenMessageId:       Int?
        var partnerLastSeenMessageNanos:    UInt?
        var partnerLastSeenMessageTime:     UInt?
        var pin:                            Bool?
        var time:                           UInt?
        var type:                           Int?
        var unreadCount:                    Int?
        
        var inviter:                        Participant?
        var lastMessage:                    Message?
        var participants:                   [Participant]?
        var pinMessage:                     PinUnpinMessage?
        
        
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
            if let closedThread2 = self.closedThread as? Bool {
                closedThread = closedThread2
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
            if let mentioned2 = self.mentioned as? Bool {
                mentioned = mentioned2
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
            if let pin2 = self.pin as? Bool {
                pin = pin2
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
                participants = []
                for item in participantArr {
                    if let participant = item as? CMParticipant {
                        participants?.append(participant.convertCMObjectToObject())
                    }
                }
            }
            if (showInviter) {
                if let theInviter = self.inviter {
                    inviter = theInviter.convertCMObjectToObject()
                }
            }
            if (showLastMessageVO) {
                if let theLastMessage = self.lastMessageVO {
                    lastMessage = theLastMessage.convertCMObjectToObject(showConversation: false, showForwardInfo: true, showParticipant: true, showReplyInfo: true)
                }
            }
            if (showPinMessage) {
                if let thePinMessage = self.pinMessage {
                    pinMessage = thePinMessage.convertCMObjectToObject()
                }
            }
        }
        
        
        
        func createMessageModel() -> Conversation {
            let conversationModel = Conversation(admin:                 admin,
                                                 canEditInfo:           canEditInfo,
                                                 canSpam:               canSpam,
                                                 closedThread:          closedThread,
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
                                                 mentioned:             mentioned,
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
                                                 pin:                   pin,
                                                 time:                  time,
                                                 title:                 self.title,
                                                 type:                  type,
                                                 unreadCount:           unreadCount,
                                                 uniqueName:            nil,
                                                 userGroupHash:         self.userGroupHash,
                                                 inviter:               (showInviter)       ? inviter       : nil,
                                                 lastMessageVO:         (showLastMessageVO) ? lastMessage   : nil,
                                                 participants:          (showParticipants)  ? participants  : nil,
                                                 pinMessage:            (showPinMessage)    ? pinMessage    : nil)
            
            return conversationModel
        }
        
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
    
    func updateObject(with conversation: Conversation) {
        if let admin = conversation.admin as NSNumber? {
            self.admin = admin
        }
        if let canEditInfo = conversation.canEditInfo as NSNumber? {
            self.canEditInfo = canEditInfo
        }
        if let canSpam = conversation.canSpam as NSNumber? {
            self.canSpam = canSpam
        }
        if let closedThread = conversation.closedThread as NSNumber? {
            self.closedThread = closedThread
        }
        if let descriptions = conversation.description {
            self.descriptions = descriptions
        }
        if let group = conversation.group as NSNumber? {
            self.group = group
        }
        if let id = conversation.id as NSNumber? {
            self.id = id
        }
        if let image = conversation.image {
            self.image = image
        }
        if let joinDate = conversation.joinDate as NSNumber? {
            self.joinDate = joinDate
        }
        if let lastMessage = conversation.lastMessage {
            self.lastMessage = lastMessage
        }
        if let lastParticipantImage = conversation.lastParticipantImage {
            self.lastParticipantImage = lastParticipantImage
        }
        if let lastParticipantName = conversation.lastParticipantName {
            self.lastParticipantName = lastParticipantName
        }
        if let lastSeenMessageId = conversation.lastSeenMessageId as NSNumber? {
            self.lastSeenMessageId = lastSeenMessageId
        }
        if let mentioned = conversation.mentioned as NSNumber? {
            self.mentioned = mentioned
        }
        if let metadata = conversation.metadata {
            self.metadata = metadata
        }
        if let mute = conversation.mute as NSNumber? {
            self.mute = mute
        }
        if let participantCount = conversation.participantCount as NSNumber? {
            self.participantCount = participantCount
        }
        if let partner = conversation.partner as NSNumber? {
            self.partner = partner
        }
        if let partnerLastDeliveredMessageId = conversation.partnerLastDeliveredMessageId as NSNumber? {
            self.partnerLastDeliveredMessageId = partnerLastDeliveredMessageId
        }
        if let partnerLastSeenMessageId = conversation.partnerLastSeenMessageId as NSNumber? {
            self.partnerLastSeenMessageId = partnerLastSeenMessageId
        }
        if let pin = conversation.pin as NSNumber? {
            self.pin = pin
        }
        if let title = conversation.title {
            self.title = title
        }
        if let time = conversation.time as NSNumber? {
            self.time = time
        }
        if let type = conversation.type as NSNumber? {
            self.type = type
        }
        if let unreadCount = conversation.unreadCount as NSNumber? {
            self.unreadCount = unreadCount
        }
        if let userGroupHash = conversation.userGroupHash {
            self.userGroupHash  = userGroupHash
        }
    }
    
    
}
