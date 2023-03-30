//
//  CDMutualGroup+CoreDataProperties.swift
//  FanapPodChatSDK
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDMutualGroup {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDMutualGroup> {
        NSFetchRequest<CDMutualGroup>(entityName: "CDMutualGroup")
    }

    static let entityName = "CDMutualGroup"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDMutualGroup {
        CDMutualGroup(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var idType: NSNumber?
    @NSManaged var mutualId: String?
    @NSManaged var conversations: NSSet?
}

// MARK: Generated accessors for conversations

public extension CDMutualGroup {
    @objc(addConversationsObject:)
    @NSManaged func addToConversations(_ value: CDConversation)

    @objc(removeConversationsObject:)
    @NSManaged func removeFromConversations(_ value: CDConversation)

    @objc(addConversations:)
    @NSManaged func addToConversations(_ values: NSSet)

    @objc(removeConversations:)
    @NSManaged func removeFromConversations(_ values: NSSet)
}

public extension CDMutualGroup {
    func update(_ model: MutualGroup) {
        idType = model.idType?.rawValue as? NSNumber
        mutualId = model.mutualId
    }

    var codable: MutualGroup {
        MutualGroup(idType: InviteeTypes(rawValue: Int(truncating: idType ?? -1)) ?? .unknown,
                    mutualId: mutualId,
                    conversations: conversations?.allObjects.compactMap { $0 as? CDConversation }.map { $0.codable() })
    }
}
