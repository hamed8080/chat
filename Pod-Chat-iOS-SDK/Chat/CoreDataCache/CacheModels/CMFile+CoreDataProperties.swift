//
//  CMFile+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMFile {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMFile> {
        return NSFetchRequest<CMFile>(entityName: "CMFile")
    }
    
    @NSManaged public var hashCode: String?
//    @NSManaged public var id:       NSNumber?
    @NSManaged public var name:     String?
    @NSManaged public var size:     NSNumber?
    @NSManaged public var type:     String?
    
}
