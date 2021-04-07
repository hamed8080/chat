//
//  CMReplyInfo+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMReplyInfo {

	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMReplyInfo> {
        return NSFetchRequest<CMReplyInfo>(entityName: "CMReplyInfo")
    }
    
    @NSManaged public var messageId:        NSNumber?
    
    @NSManaged public var deletedd:         NSNumber?
    @NSManaged public var message:          String?
    @NSManaged public var messageType:      NSNumber?
    @NSManaged public var metadata:         String?
    @NSManaged public var repliedToMessageId: NSNumber?
    @NSManaged public var systemMetadata:   String?
    @NSManaged public var time:             NSNumber?
    @NSManaged public var dummyMessage:     CMMessage?
    @NSManaged public var participant:      CMParticipant?

}
