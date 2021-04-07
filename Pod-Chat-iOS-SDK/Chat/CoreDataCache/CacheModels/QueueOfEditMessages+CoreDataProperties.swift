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

	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfEditMessages> {
        return NSFetchRequest<QueueOfEditMessages>(entityName: "QueueOfEditMessages")
    }

    @NSManaged public var textMessage:  String?
    @NSManaged public var messageType:  NSNumber?
//    @NSManaged public var metadata:     NSObject?
    @NSManaged public var metadata:     String?
    @NSManaged public var repliedTo:    NSNumber?
    @NSManaged public var messageId:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var typeCode:     String?
    @NSManaged public var uniqueId:     String?

}
