//
//  CMUploadFile+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMUploadFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMUploadFile> {
        return NSFetchRequest<CMUploadFile>(entityName: "CMUploadFile")
    }

    @NSManaged public var hashCode: String?
    @NSManaged public var id:       NSNumber?
    @NSManaged public var name:     String?

}
