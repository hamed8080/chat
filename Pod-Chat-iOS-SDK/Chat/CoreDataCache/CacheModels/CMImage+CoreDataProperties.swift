//
//  CMImage+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMImage {
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMImage> {
        return NSFetchRequest<CMImage>(entityName: "CMImage")
    }
    
    @NSManaged public var actualHeight: NSNumber?
    @NSManaged public var actualWidth:  NSNumber?
    @NSManaged public var hashCode:     String?
    @NSManaged public var height:       NSNumber?
//    @NSManaged public var id:           NSNumber?
    @NSManaged public var isThumbnail:  NSNumber?
    @NSManaged public var name:         String?
    @NSManaged public var size:         NSNumber?
    @NSManaged public var width:        NSNumber?
    
}
