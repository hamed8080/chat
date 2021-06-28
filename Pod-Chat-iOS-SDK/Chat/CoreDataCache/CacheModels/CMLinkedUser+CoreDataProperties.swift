//
//  CMLinkedUser+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/10/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMLinkedUser {

	@available(*,deprecated , message:"Removed in 0.10.5.0 version. use new version of method")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMLinkedUser> {
        return NSFetchRequest<CMLinkedUser>(entityName: "CMLinkedUser")
    }

    @NSManaged public var coreUserId:   NSNumber?
    @NSManaged public var image:        String?
    @NSManaged public var name:         String?
    @NSManaged public var nickname:     String?
    @NSManaged public var username:     String?
    
    @NSManaged public var dummyContact: CMContact?

}
