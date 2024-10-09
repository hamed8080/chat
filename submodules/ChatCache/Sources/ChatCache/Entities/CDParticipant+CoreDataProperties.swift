//
// CDParticipant+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels
import Additive

public extension CDParticipant {
    typealias Entity = CDParticipant
    typealias Model = Participant
    typealias Id = NSNumber
    static let name = "CDParticipant"
    static var queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDParticipant {
    @NSManaged var admin: NSNumber?
    @NSManaged var auditor: NSNumber?
    @NSManaged var bio: String?
    @NSManaged var blocked: NSNumber?
    @NSManaged var cellphoneNumber: String?
    @NSManaged var contactFirstName: String?
    @NSManaged var contactId: NSNumber?
    @NSManaged var contactLastName: String?
    @NSManaged var contactName: String?
    @NSManaged var coreUserId: NSNumber?
    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var id: NSNumber?
    @NSManaged var ssoId: String?
    @NSManaged var image: String?
    @NSManaged var keyId: String?
    @NSManaged var lastName: String?
    @NSManaged var metadata: String?
    @NSManaged var myFriend: NSNumber?
    @NSManaged var name: String?
    @NSManaged var notSeenDuration: NSNumber?
    @NSManaged var online: NSNumber?
    @NSManaged var receiveEnable: NSNumber?
    @NSManaged var roles: Data?
    @NSManaged var sendEnable: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var username: String?
    @NSManaged var assistant: NSSet?
    @NSManaged var conversation: CDConversation?
    @NSManaged var forwardInfos: NSSet?
    @NSManaged var inviter: CDConversation?
    @NSManaged var messages: NSSet?
}

// MARK: Generated accessors for assistant

public extension CDParticipant {
    @objc(addAssistantObject:)
    @NSManaged func addToAssistant(_ value: CDAssistant)

    @objc(removeAssistantObject:)
    @NSManaged func removeFromAssistant(_ value: CDAssistant)

    @objc(addAssistant:)
    @NSManaged func addToAssistant(_ values: NSSet)

    @objc(removeAssistant:)
    @NSManaged func removeFromAssistant(_ values: NSSet)
}

// MARK: Generated accessors for messages

public extension CDParticipant {
    @objc(addMessagesObject:)
    @NSManaged func addToMessages(_ value: CDMessage)

    @objc(removeMessagesObject:)
    @NSManaged func removeFromMessages(_ value: CDMessage)

    @objc(addMessages:)
    @NSManaged func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged func removeFromMessages(_ values: NSSet)
}

public extension CDParticipant {
    func update(_ model: Model) {
        admin = model.admin as? NSNumber ?? admin
        auditor = model.auditor as? NSNumber ?? auditor
        blocked = model.blocked as? NSNumber ?? blocked
        cellphoneNumber = model.cellphoneNumber ?? cellphoneNumber
        contactFirstName = model.contactFirstName ?? contactFirstName
        contactId = model.contactId as? NSNumber ?? contactId
        contactName = model.contactName ?? contactName
        contactLastName = model.contactLastName ?? contactLastName
        coreUserId = model.coreUserId as? NSNumber ?? coreUserId
        email = model.email ?? email
        firstName = model.firstName ?? firstName
        id = model.id as? NSNumber ?? id
        image = model.image ?? image
        keyId = model.keyId ?? keyId
        lastName = model.lastName ?? lastName
        myFriend = model.myFriend as? NSNumber ?? myFriend
        name = model.name ?? name
        notSeenDuration = model.notSeenDuration as? NSNumber ?? notSeenDuration
        online = model.online as? NSNumber ?? online
        receiveEnable = model.receiveEnable as? NSNumber ?? receiveEnable
        sendEnable = model.sendEnable as? NSNumber ?? sendEnable
        username = model.username ?? username
        roles = model.roles?.data ?? roles
        bio = model.chatProfileVO?.bio ?? bio
        ssoId = model.ssoId ?? ssoId
        metadata = model.chatProfileVO?.metadata ?? metadata
    }

    class func findOrCreate(threadId: Int, participantId: Int, context: NSManagedObjectContextProtocol) -> CDParticipant {
        let req = CDParticipant.fetchRequest()
        req.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(CDParticipant.id), participantId.nsValue,
                                    #keyPath(CDParticipant.conversation.id), threadId.nsValue
        )
        let entity = (try? context.fetch(req).first) ?? CDParticipant.insertEntity(context)
        return entity
    }

    var codable: Model {
        var decodedRoles: [Roles]?
        if let roles = self.roles {
            decodedRoles = try? JSONDecoder.instance.decode([Roles].self, from: roles)
        }
        return Participant(admin: admin?.boolValue,
                           auditor: auditor?.boolValue,
                           blocked: blocked?.boolValue,
                           cellphoneNumber: cellphoneNumber,
                           contactFirstName: contactFirstName,
                           contactId: contactId?.intValue,
                           contactName: contactName,
                           contactLastName: contactLastName,
                           coreUserId: coreUserId?.intValue,
                           email: email,
                           firstName: firstName,
                           id: id?.intValue,
                           ssoId: ssoId,
                           image: image,
                           keyId: keyId,
                           lastName: lastName,
                           myFriend: myFriend?.boolValue,
                           name: name,
                           notSeenDuration: notSeenDuration?.intValue,
                           online: online?.boolValue,
                           receiveEnable: receiveEnable?.boolValue,
                           roles: decodedRoles,
                           sendEnable: sendEnable?.boolValue,
                           username: username,
                           chatProfileVO: .init(bio: bio, metadata: metadata),
                           conversation: conversation?.codable(fillLastMessageVO: false, fillParticipants: false).toParticipantConversation)
    }
}
