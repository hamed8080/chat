//
//  QueueOfUploadImages+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfUploadImages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfUploadImages> {
        return NSFetchRequest<QueueOfUploadImages>(entityName: "QueueOfUploadImages")
    }
    
    @NSManaged public var dataToSend:       NSData?
    @NSManaged public var fileExtension:    String?
    @NSManaged public var fileName:         String?
    @NSManaged public var fileSize:         NSNumber?
    @NSManaged public var isPublic:         NSNumber?
    @NSManaged public var mimeType:         String?
    @NSManaged public var originalName:     String?
    @NSManaged public var userGroupHash:    String?
    @NSManaged public var typeCode:         String?
    @NSManaged public var uniqueId:         String?
    @NSManaged public var xC:               NSNumber?
    @NSManaged public var yC:               NSNumber?
    @NSManaged public var hC:               NSNumber?
    @NSManaged public var wC:               NSNumber?

}
