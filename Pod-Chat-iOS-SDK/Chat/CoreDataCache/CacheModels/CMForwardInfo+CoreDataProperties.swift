//
//  CMForwardInfo+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMForwardInfo {

	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMForwardInfo> {
        return NSFetchRequest<CMForwardInfo>(entityName: "CMForwardInfo")
    }
    
    @NSManaged public var messageId:    NSNumber?
    
    @NSManaged public var conversation: CMConversation?
    @NSManaged public var dummyMessage: CMMessage?
    @NSManaged public var participant:  CMParticipant?

}
