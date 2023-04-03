//
//  CDAssistant+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import Additive
import CoreData
import Foundation

public extension CDAssistant {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDAssistant> {
        NSFetchRequest<CDAssistant>(entityName: "CDAssistant")
    }

    static let entityName = "CDAssistant"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDAssistant {
        CDAssistant(entity: entityDescription(context), insertInto: context)
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
        roles = assistant.roles?.data
        block = assistant.block as? NSNumber
    }

    var codable: Assistant {
        Assistant(contactType: contactType,
                  assistant: assistant,
                  participant: participant?.codable,
                  roles: try? JSONDecoder.instance.decode([Roles].self, from: roles ?? Data()),
                  block: block?.boolValue)
    }
}
