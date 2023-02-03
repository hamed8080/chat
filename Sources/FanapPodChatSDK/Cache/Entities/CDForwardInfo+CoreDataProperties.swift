//
//  CDForwardInfo+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDForwardInfo {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDForwardInfo> {
        NSFetchRequest<CDForwardInfo>(entityName: "CDForwardInfo")
    }

    @NSManaged var messageId: NSNumber?
    @NSManaged var conversation: CDConversation?
    @NSManaged var message: CDMessage?
    @NSManaged var participant: CDParticipant?
}

public extension CDForwardInfo {
    var codable: ForwardInfo {
        ForwardInfo(conversation: conversation?.codable(), participant: participant?.codable)
    }
}
