//
//  CMUser+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/10/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMUser {

	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMUser> {
        return NSFetchRequest<CMUser>(entityName: "CMUser")
    }

    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var contactSynced:    NSNumber?
    @NSManaged public var coreUserId:       NSNumber?
    @NSManaged public var email:            String?
    @NSManaged public var id:               NSNumber?
    @NSManaged public var image:            String?
    @NSManaged public var lastSeen:         NSNumber?
    @NSManaged public var name:             String?
    @NSManaged public var receiveEnable:    NSNumber?
    @NSManaged public var sendEnable:       NSNumber?
    @NSManaged public var username:         String?
    
    @NSManaged public var bio:              String?
    @NSManaged public var metadata:         String?
    
}
