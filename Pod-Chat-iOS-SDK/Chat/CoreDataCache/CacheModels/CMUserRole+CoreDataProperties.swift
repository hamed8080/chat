//
//  CMUserRole+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


extension CMUserRole {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMUserRole> {
        return NSFetchRequest<CMUserRole>(entityName: "CMUserRole")
    }

    @NSManaged public var id:           NSNumber?
    @NSManaged public var name:         String?
    @NSManaged public var threadId:     NSNumber?
    @NSManaged public var roles:        NSObject?
    @NSManaged public var conversation: NSSet?

}

// MARK: Generated accessors for conversation
extension CMUserRole {

    @objc(addConversationObject:)
    @NSManaged public func addToConversation(_ value: CMConversation)

    @objc(removeConversationObject:)
    @NSManaged public func removeFromConversation(_ value: CMConversation)

    @objc(addConversation:)
    @NSManaged public func addToConversation(_ values: NSSet)

    @objc(removeConversation:)
    @NSManaged public func removeFromConversation(_ values: NSSet)

}
