//
//  ThreadAdmins+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 5/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension ThreadAdmins {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThreadAdmins> {
        return NSFetchRequest<ThreadAdmins>(entityName: "ThreadAdmins")
    }

    @NSManaged public var threadId: NSNumber?
    @NSManaged public var roles:    [String]?
    @NSManaged public var userId:   NSNumber?
    @NSManaged public var name:     String?

}
