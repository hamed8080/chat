//
//  CMMessage+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMMessage {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMMessage> {
        return NSFetchRequest<CMMessage>(entityName: "CMMessage")
    }
    
    @NSManaged public var deletable:        NSNumber?
    @NSManaged public var delivered:        NSNumber?
    @NSManaged public var editable:         NSNumber?
    @NSManaged public var edited:           NSNumber?
    @NSManaged public var id:               NSNumber?
    @NSManaged public var mentioned:        NSNumber?
    @NSManaged public var message:          String?
    @NSManaged public var messageType:      String?
    @NSManaged public var metadata:         String?
    @NSManaged public var ownerId:          NSNumber?
    @NSManaged public var pinned:           NSNumber?
    @NSManaged public var previousId:       NSNumber?
    @NSManaged public var seen:             NSNumber?
    @NSManaged public var systemMetadata:   String?
    @NSManaged public var threadId:         NSNumber?
    @NSManaged public var time:             NSNumber?
    @NSManaged public var uniqueId:         String?
    @NSManaged public var conversation:     CMConversation?
    @NSManaged public var dummyConversationLastMessageVO: CMConversation?
    @NSManaged public var forwardInfo:      CMForwardInfo?
    @NSManaged public var participant:      CMParticipant?
    @NSManaged public var replyInfo:        CMReplyInfo?
    
}
