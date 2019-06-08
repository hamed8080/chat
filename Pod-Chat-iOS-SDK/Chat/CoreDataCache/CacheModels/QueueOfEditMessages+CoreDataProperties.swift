//
//  QueueOfEditMessages+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfEditMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfEditMessages> {
        return NSFetchRequest<QueueOfEditMessages>(entityName: "QueueOfEditMessages")
    }

    @NSManaged public var content:      String?
    @NSManaged public var metaData:     NSObject?
    @NSManaged public var repliedTo:    NSNumber?
    @NSManaged public var subjectId:    NSNumber?
    @NSManaged public var typeCode:     String?
    @NSManaged public var uniqueId:     String?

}
