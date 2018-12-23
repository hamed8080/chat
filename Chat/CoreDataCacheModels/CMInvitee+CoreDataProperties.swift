//
//  CMInvitee+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMInvitee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMInvitee> {
        return NSFetchRequest<CMInvitee>(entityName: "CMInvitee")
    }

    @NSManaged public var id:       String?
    @NSManaged public var idType:   NSNumber?

}
