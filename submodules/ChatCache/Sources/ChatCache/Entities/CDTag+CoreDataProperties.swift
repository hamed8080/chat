//
// CDTag+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDTag {
    typealias Entity = CDTag
    typealias Model = Tag
    typealias Id = NSNumber
    static let name = "CDTag"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDTag {
    @NSManaged var active: NSNumber?
    @NSManaged var id: NSNumber
    @NSManaged var name: String?
    @NSManaged var tagParticipants: NSSet?
}

// MARK: Generated accessors for tagParticipants

public extension CDTag {
    @objc(addTagParticipantsObject:)
    @NSManaged func addToTagParticipants(_ value: CDTagParticipant)

    @objc(removeTagParticipantsObject:)
    @NSManaged func removeFromTagParticipants(_ value: CDTagParticipant)

    @objc(addTagParticipants:)
    @NSManaged func addToTagParticipants(_ values: NSSet)

    @objc(removeTagParticipants:)
    @NSManaged func removeFromTagParticipants(_ values: NSSet)
}

public extension CDTag {
    func update(_ model: Model) {
        id = model.id as NSNumber
        name = model.name
        active = model.active as NSNumber
        model.tagParticipants?.forEach{ participnat in
            if let context = managedObjectContext {
                let participantEntity = CDTagParticipant.insertEntity(context)
                participantEntity.update(participnat)
                participantEntity.tag = self
                participantEntity.tagId = id
                addToTagParticipants(participantEntity)
            }
        }
    }

    var codable: Model {
        Tag(id: id.intValue,
            name: name ?? "",
            active: active?.boolValue ?? false,
            tagParticipants: tagParticipants?.allObjects.compactMap{ $0 as? CDTagParticipant }.compactMap{ $0?.codable } )
    }
}
