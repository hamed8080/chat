//
//  QueueOfUploadFiles+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueOfUploadFiles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueOfUploadFiles> {
        return NSFetchRequest<QueueOfUploadFiles>(entityName: "QueueOfUploadFiles")
    }
    @NSManaged public var dataToSend:       NSData?
    @NSManaged public var fileExtension:    String?
    @NSManaged public var fileName:         String?
    @NSManaged public var fileSize:         NSNumber?
    @NSManaged public var mimeType:         String?
    @NSManaged public var originalFileName: String?
    @NSManaged public var threadId:         NSNumber?
    @NSManaged public var typeCode:         String?
    @NSManaged public var uniqueId:         String?

}
