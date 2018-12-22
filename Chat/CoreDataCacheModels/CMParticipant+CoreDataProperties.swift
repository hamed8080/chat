//
//  CMParticipant+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMParticipant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMParticipant> {
        return NSFetchRequest<CMParticipant>(entityName: "CMParticipant")
    }

    @NSManaged public var admin: NSNumber?
    @NSManaged public var blocked: NSNumber?
    @NSManaged public var cellphoneNumber: String?
    @NSManaged public var contactId: NSNumber?
    @NSManaged public var coreUserId: NSNumber?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var image: String?
    @NSManaged public var lastName: String?
    @NSManaged public var myFriend: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var notSeenDuration: NSNumber?
    @NSManaged public var online: NSNumber?
    @NSManaged public var receiveEnable: NSNumber?
    @NSManaged public var sendEnable: NSNumber?

}
