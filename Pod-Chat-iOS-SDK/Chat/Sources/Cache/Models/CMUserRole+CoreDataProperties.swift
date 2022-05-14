//
//  CMUserRole.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//


import Foundation
import CoreData

extension CMUserRole {
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
