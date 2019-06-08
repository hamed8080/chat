//
//  CMUserRole+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
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
    @NSManaged public var conversation: [CMConversation]?

}

// MARK: Generated accessors for conversation
extension CMUserRole {

    @objc(addConversationObject:)
    @NSManaged public func addToConversation(_ value: CMConversation)

    @objc(removeConversationObject:)
    @NSManaged public func removeFromConversation(_ value: CMConversation)

    @objc(addConversation:)
    @NSManaged public func addToConversation(_ values: [CMConversation])

    @objc(removeConversation:)
    @NSManaged public func removeFromConversation(_ values: [CMConversation])

}
