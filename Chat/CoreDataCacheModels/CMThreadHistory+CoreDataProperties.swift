//
//  CMThreadHistory+CoreDataProperties.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMThreadHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMThreadHistory> {
        return NSFetchRequest<CMThreadHistory>(entityName: "CMThreadHistory")
    }

    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension CMThreadHistory {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: CMMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: CMMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
