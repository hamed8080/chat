//
//  CMCurrentUserRoles+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMCurrentUserRoles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMCurrentUserRoles> {
        return NSFetchRequest<CMCurrentUserRoles>(entityName: "CMCurrentUserRoles")
    }

    @NSManaged public var threadId: NSNumber?
    @NSManaged public var roles:    RolesArray?

}
