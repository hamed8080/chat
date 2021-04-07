//
//  QueueOfTextMessages+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfTextMessages {
	
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfTextMessages> {
        return NSFetchRequest<QueueOfTextMessages>(entityName: "QueueOfTextMessages")
    }

    @NSManaged public var textMessage:      String?
    @NSManaged public var messageType:      NSNumber?
    @NSManaged public var repliedTo:        NSNumber?
    @NSManaged public var threadId:         NSNumber?
    @NSManaged public var typeCode:         String?
    @NSManaged public var uniqueId:         String?
//    @NSManaged public var metadata:         NSObject?
    @NSManaged public var metadata:         String?
//    @NSManaged public var systemMetadata:   NSObject?
    @NSManaged public var systemMetadata:   String?

}
