//
//  CMThreadParticipants+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMThreadParticipants {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMThreadParticipants> {
        return NSFetchRequest<CMThreadParticipants>(entityName: "CMThreadParticipants")
    }

    @NSManaged public var participants: [CMParticipant]?

}

// MARK: Generated accessors for participants
extension CMThreadParticipants {

    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: CMParticipant)

    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: CMParticipant)

    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: [CMParticipant])

    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: [CMParticipant])

}
