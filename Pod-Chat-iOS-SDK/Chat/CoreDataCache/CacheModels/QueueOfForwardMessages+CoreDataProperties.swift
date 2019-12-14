//
//  QueueOfForwardMessages+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfForwardMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfForwardMessages> {
        return NSFetchRequest<QueueOfForwardMessages>(entityName: "QueueOfForwardMessages")
    }

//    @NSManaged public var messageIds:   [NSNumber]?
    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var metaData:     NSObject?
    @NSManaged public var repliedTo:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var typeCode:     String?
    @NSManaged public var uniqueId:     String?

}
