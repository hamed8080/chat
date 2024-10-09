//
// CDTagParticipant+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import ChatModels
import Foundation

public extension CDTagParticipant {
    typealias Entity = CDTagParticipant
    typealias Model = TagParticipant
    typealias Id = NSNumber
    static let name = "CDTagParticipant"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDTagParticipant {
    @NSManaged var active: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var tagId: NSNumber?
    @NSManaged var threadId: NSNumber?
    @NSManaged var conversation: CDConversation?
    @NSManaged var tag: CDTag?
}

public extension CDTagParticipant {
    func update(_ model: Model) {
        id = model.id as? NSNumber ?? id
        active = model.active as? NSNumber ?? active
        tagId = model.tagId as? NSNumber ?? tagId
        id = model.id as? NSNumber ?? id
        threadId = model.conversation?.id as? NSNumber ?? threadId
        if let context = managedObjectContext, let thread = model.conversation, let threadId = thread.id {
            let threadEntity = CDConversation.findOrCreate(threadId: threadId, context: context)
            threadEntity.update(thread)
            conversation = threadEntity
        }
    }

    var codable: Model {
        TagParticipant(id: id?.intValue,
                       active: active?.boolValue,
                       tagId: tagId?.intValue,
                       threadId: threadId?.intValue,
                       conversation: conversation?.codable())
    }
}
