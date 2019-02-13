//
//  CMThreadParticipants+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMThreadParticipants {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMThreadParticipants> {
        return NSFetchRequest<CMThreadParticipants>(entityName: "CMThreadParticipants")
    }
    
    @NSManaged public var threadId:         NSNumber?
    @NSManaged public var participantId:    NSNumber?
    @NSManaged public var time:             NSNumber?
    
}
