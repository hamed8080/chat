//
//  CMUploadImage+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMUploadImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMUploadImage> {
        return NSFetchRequest<CMUploadImage>(entityName: "CMUploadImage")
    }

    @NSManaged public var actualHeight: NSNumber?
    @NSManaged public var actualWidth:  NSNumber?
    @NSManaged public var hashCode: String?
    @NSManaged public var height:   NSNumber?
    @NSManaged public var id:       NSNumber?
    @NSManaged public var name:     String?
    @NSManaged public var width:    NSNumber?

}
