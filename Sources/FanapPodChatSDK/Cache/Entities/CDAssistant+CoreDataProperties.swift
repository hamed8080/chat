//
//  CDAssistant+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDAssistant {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDAssistant> {
        NSFetchRequest<CDAssistant>(entityName: "CDAssistant")
    }

    @NSManaged var assistant: Invitee?
    @NSManaged var block: NSNumber?
    @NSManaged var contactType: String?
    @NSManaged var inviteeId: Int64
    @NSManaged var roles: Data?
    @NSManaged var participant: CDParticipant?
}

public extension CDAssistant {
    func update(_ assistant: Assistant) {
        contactType = assistant.contactType
        self.assistant = assistant.assistant
        if let participant = assistant.participant, let context = managedObjectContext {
            let entity = CDParticipant(context: context)
            entity.update(participant)
        }
        roles = assistant.roles?.toData()
        block = assistant.block as? NSNumber
    }

    var codable: Assistant {
        Assistant(contactType: contactType,
                  assistant: assistant,
                  participant: participant?.codable,
                  roles: try? JSONDecoder().decode([Roles].self, from: roles ?? Data()),
                  block: block?.boolValue)
    }
}
