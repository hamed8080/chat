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
    func update(_ forwardInfo: ForwardInfo) {
        guard let context = managedObjectContext else { print("Conetxt is nil"); return }
        if let participant = forwardInfo.participant {
            let entity = CDParticipant(context: context)
            entity.update(participant)
        }

        if let conversation = forwardInfo.conversation {
            let entity = CDConversation(context: context)
            entity.update(conversation)
        }
    }

    var codable: ForwardInfo {
        ForwardInfo(conversation: conversation?.codable, participant: participant?.codable)
    }
}
