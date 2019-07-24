//
//  CMParticipant+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/2/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData

extension CMParticipant {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMParticipant> {
        return NSFetchRequest<CMParticipant>(entityName: "CMParticipant")
    }
    
    @NSManaged public var admin:            NSNumber?
    @NSManaged public var blocked:          NSNumber?
    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var contactId:        NSNumber?
    @NSManaged public var coreUserId:       NSNumber?
    @NSManaged public var email:            String?
    @NSManaged public var firstName:        String?
    @NSManaged public var id:               NSNumber?
    @NSManaged public var image:            String?
    @NSManaged public var lastName:         String?
    @NSManaged public var myFriend:         NSNumber?
    @NSManaged public var name:             String?
    @NSManaged public var notSeenDuration:  NSNumber?
    @NSManaged public var online:           NSNumber?
    @NSManaged public var receiveEnable:    NSNumber?
    @NSManaged public var roles:            [String]?
    @NSManaged public var sendEnable:       NSNumber?
    @NSManaged public var dummyConversationInviter:         [CMConversation]?
    @NSManaged public var dummyConversationParticipants:    [CMConversation]?
    @NSManaged public var dummyForwardInfo: CMForwardInfo?
    @NSManaged public var dummyMessage:     [CMMessage]?
    @NSManaged public var dummyReplyInfo:   CMReplyInfo?
    
}

// MARK: Generated accessors for dummyConversationInviter
extension CMParticipant {
    
    @objc(addDummyConversationInviterObject:)
    @NSManaged public func addToDummyConversationInviter(_ value: CMConversation)
    
    @objc(removeDummyConversationInviterObject:)
    @NSManaged public func removeFromDummyConversationInviter(_ value: CMConversation)
    
    @objc(addDummyConversationInviter:)
    @NSManaged public func addToDummyConversationInviter(_ values: [CMConversation])
    
    @objc(removeDummyConversationInviter:)
    @NSManaged public func removeFromDummyConversationInviter(_ values: [CMConversation])
    
}

// MARK: Generated accessors for dummyConversationParticipants
extension CMParticipant {
    
    @objc(addDummyConversationParticipantsObject:)
    @NSManaged public func addToDummyConversationParticipants(_ value: CMConversation)
    
    @objc(removeDummyConversationParticipantsObject:)
    @NSManaged public func removeFromDummyConversationParticipants(_ value: CMConversation)
    
    @objc(addDummyConversationParticipants:)
    @NSManaged public func addToDummyConversationParticipants(_ values: [CMConversation])
    
    @objc(removeDummyConversationParticipants:)
    @NSManaged public func removeFromDummyConversationParticipants(_ values: [CMConversation])
    
}

// MARK: Generated accessors for dummyMessage
extension CMParticipant {
    
    @objc(addDummyMessageObject:)
    @NSManaged public func addToDummyMessage(_ value: CMMessage)
    
    @objc(removeDummyMessageObject:)
    @NSManaged public func removeFromDummyMessage(_ value: CMMessage)
    
    @objc(addDummyMessage:)
    @NSManaged public func addToDummyMessage(_ values: [CMMessage])
    
    @objc(removeDummyMessage:)
    @NSManaged public func removeFromDummyMessage(_ values: [CMMessage])
    
}
