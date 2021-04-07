//
//  PhoneContact+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension PhoneContact {
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneContact> {
        return NSFetchRequest<PhoneContact>(entityName: "PhoneContact")
    }
    
    @NSManaged public var cellphoneNumber:  String?
    @NSManaged public var email:            String?
    @NSManaged public var firstName:        String?
    @NSManaged public var lastName:         String?
    
}
