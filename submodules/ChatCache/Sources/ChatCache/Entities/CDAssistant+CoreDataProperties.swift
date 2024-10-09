//
// CDAssistant+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels
import Additive

public extension CDAssistant {
    typealias Entity = CDAssistant
    typealias Model = Assistant
    typealias Id = NSNumber
    static let name = "CDAssistant"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDAssistant {
    @NSManaged var id: NSNumber?
    @NSManaged var assistant: InviteeClass?
    @NSManaged var block: NSNumber?
    @NSManaged var contactType: String?
    @NSManaged var inviteeId: Int64
    @NSManaged var roles: Data?
    @NSManaged var participant: CDParticipant?
}

public extension CDAssistant {
    func update(_ model: Model) {
        id = model.participant?.id as? NSNumber ?? id
        contactType = model.contactType ?? contactType
        self.assistant = model.assistant?.toClass ?? assistant
        roles = model.roles?.data ?? roles
        block = model.block as? NSNumber ?? block
        setParticipant(model: model)
    }
    
    func setParticipant(model: Model) {
        guard let context = managedObjectContext else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDParticipant.id), (model.participant?.id ?? 0).nsValue)
        let req = CDParticipant.fetchRequest()
        req.predicate = predicate
        if let participantEntity = try? context.fetch(req).first {
            self.participant = participantEntity
        } else if let participantModel = model.participant {
            let participantEntity = CDParticipant.insertEntity(context)
            participantEntity.update(participantModel)
            self.participant = participantEntity
        }
    }

    var codable: Model {
        var decodededRoles: [Roles]?
        if let data = roles, let roles = try? JSONDecoder.instance.decode([Roles].self, from: data) {
            decodededRoles = roles
        }
        return Assistant(id: id?.intValue,
                         contactType: contactType,
                         assistant: assistant?.toStruct,
                         participant: participant?.codable,
                         roles: decodededRoles,
                         block: block?.boolValue)
    }
}
