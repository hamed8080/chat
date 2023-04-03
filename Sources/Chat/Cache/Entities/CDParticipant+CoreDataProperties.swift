//
//  CDParticipant+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDParticipant {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDParticipant> {
        NSFetchRequest<CDParticipant>(entityName: "CDParticipant")
    }

    static let entityName = "CDParticipant"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDParticipant {
        CDParticipant(entity: entityDescription(context), insertInto: context)
    }

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
    @NSManaged var replyInfo: NSSet?
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

// MARK: Generated accessors for forwardInfos

public extension CDParticipant {
    @objc(addForwardInfosObject:)
    @NSManaged func addToForwardInfos(_ value: CDForwardInfo)

    @objc(removeForwardInfosObject:)
    @NSManaged func removeFromForwardInfos(_ value: CDForwardInfo)

    @objc(addForwardInfos:)
    @NSManaged func addToForwardInfos(_ values: NSSet)

    @objc(removeForwardInfos:)
    @NSManaged func removeFromForwardInfos(_ values: NSSet)
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

// MARK: Generated accessors for replyInfo

public extension CDParticipant {
    @objc(addReplyInfoObject:)
    @NSManaged func addToReplyInfo(_ value: CDReplyInfo)

    @objc(removeReplyInfoObject:)
    @NSManaged func removeFromReplyInfo(_ value: CDReplyInfo)

    @objc(addReplyInfo:)
    @NSManaged func addToReplyInfo(_ values: NSSet)

    @objc(removeReplyInfo:)
    @NSManaged func removeFromReplyInfo(_ values: NSSet)
}

public extension CDParticipant {
    func update(_ participant: Participant) {
        admin = participant.admin as? NSNumber
        auditor = participant.auditor as? NSNumber
        blocked = participant.blocked as? NSNumber
        cellphoneNumber = participant.cellphoneNumber
        contactFirstName = participant.contactFirstName
        contactId = participant.contactId as? NSNumber
        contactName = participant.contactName
        contactLastName = participant.contactLastName
        coreUserId = participant.coreUserId as? NSNumber
        email = participant.email
        firstName = participant.firstName
        id = participant.id as? NSNumber
        image = participant.image
        keyId = participant.keyId
        lastName = participant.lastName
        myFriend = participant.myFriend as? NSNumber
        name = participant.name
        notSeenDuration = participant.notSeenDuration as? NSNumber
        online = participant.online as? NSNumber
        receiveEnable = participant.receiveEnable as? NSNumber
        sendEnable = participant.sendEnable as? NSNumber
        username = participant.username
        roles = participant.roles?.data
        bio = participant.chatProfileVO?.bio
        ssoId = participant.ssoId
        metadata = participant.chatProfileVO?.metadata
    }

    var codable: Participant {
        Participant(admin: admin?.boolValue,
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
                    roles: try? JSONDecoder.instance.decode([Roles].self, from: roles ?? Data()),
                    sendEnable: sendEnable?.boolValue,
                    username: username,
                    chatProfileVO: .init(bio: bio, metadata: metadata),
                    conversation: conversation?.codable(fillLastMessageVO: false, fillParticipants: false, fillPinMessages: false))
    }
}
