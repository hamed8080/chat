//
//  QueueOfFileMessages+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfFileMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfFileMessages> {
        return NSFetchRequest<QueueOfFileMessages>(entityName: "QueueOfFileMessages")
    }

    @NSManaged public var textMessage:  String?
    @NSManaged public var fileExtension: String?
    @NSManaged public var fileName:     String?
    @NSManaged public var isPublic:     NSNumber?
    @NSManaged public var messageType:  NSNumber?
    @NSManaged public var metadata:     String?
    @NSManaged public var mimeType:     String?
    @NSManaged public var originalName: String?
    @NSManaged public var repliedTo:    NSNumber?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var userGroupHash: String?
    
//    @NSManaged public var imageName:    String?
    @NSManaged public var xC:           NSNumber?
    @NSManaged public var yC:           NSNumber?
    @NSManaged public var hC:           NSNumber?
    @NSManaged public var wC:           NSNumber?
    
    @NSManaged public var typeCode:     String?
    @NSManaged public var uniqueId:     String?
    
    @NSManaged public var fileToSend:   NSData?
    @NSManaged public var imageToSend:  NSData?

}
