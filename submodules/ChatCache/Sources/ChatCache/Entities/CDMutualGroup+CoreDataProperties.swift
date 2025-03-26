//
// CDMutualGroup+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDMutualGroup {
    typealias Entity = CDMutualGroup
    typealias Model = MutualGroup
    typealias Id = NSNumber
    static let name = "CDMutualGroup"
    static let queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDMutualGroup {
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
    func update(_ model: Model) {
        idType = model.idType?.rawValue as? NSNumber ?? idType
        mutualId = model.mutualId ?? mutualId
        model.conversations?.forEach{ thread in
            if let context = managedObjectContext?.sendable, let threadId = thread.id {
                let threadEntity = CDConversation.findOrCreate(threadId: threadId, context: context)
                threadEntity.update(thread)
                addToConversations(threadEntity)
            }
        }
    }

    var codable: Model {
        MutualGroup(idType: InviteeTypes(rawValue: Int(truncating: idType ?? -1)) ?? .unknown,
                    mutualId: mutualId,
                    conversations: conversations?.allObjects.compactMap { $0 as? CDConversation }.map { $0.codable() })
    }
}
