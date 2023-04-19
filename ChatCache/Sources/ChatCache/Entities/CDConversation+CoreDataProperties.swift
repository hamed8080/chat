//
//  CDConversation+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatModels

public extension CDConversation {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDConversation> {
        NSFetchRequest<CDConversation>(entityName: "CDConversation")
    }

    static let entityName = "CDConversation"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDConversation {
        CDConversation(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var admin: NSNumber?
    @NSManaged var canEditInfo: NSNumber?
    @NSManaged var canSpam: NSNumber?
    @NSManaged var closedThread: NSNumber?
    @NSManaged var descriptions: String?
    @NSManaged var group: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var image: String?
    @NSManaged var isArchive: NSNumber?
    @NSManaged var joinDate: NSNumber?
    @NSManaged var lastMessage: String?
    @NSManaged var lastParticipantImage: String?
    @NSManaged var lastParticipantName: String?
    @NSManaged var lastSeenMessageId: NSNumber?
    @NSManaged var lastSeenMessageNanos: NSNumber?
    @NSManaged var lastSeenMessageTime: NSNumber?
    @NSManaged var mentioned: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var mute: NSNumber?
    @NSManaged var participantCount: NSNumber?
    @NSManaged var partner: NSNumber?
    @NSManaged var partnerLastDeliveredMessageId: NSNumber?
    @NSManaged var partnerLastDeliveredMessageNanos: NSNumber?
    @NSManaged var partnerLastDeliveredMessageTime: NSNumber?
    @NSManaged var partnerLastSeenMessageId: NSNumber?
    @NSManaged var partnerLastSeenMessageNanos: NSNumber?
    @NSManaged var partnerLastSeenMessageTime: NSNumber?
    @NSManaged var pin: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var title: String?
    @NSManaged var type: NSNumber?
    @NSManaged var uniqueName: String?
    @NSManaged var unreadCount: NSNumber?
    @NSManaged var userGroupHash: String?
    @NSManaged var forwardInfos: NSSet?
    @NSManaged var inviter: CDParticipant?
    @NSManaged var lastMessageVO: CDMessage?
    @NSManaged var messages: NSSet?
    @NSManaged var mutualGroups: NSSet?
    @NSManaged var participants: NSSet?
    @NSManaged var pinMessages: NSSet?
    @NSManaged var tagParticipants: NSSet?
}

// MARK: Generated accessors for forwardInfos

public extension CDConversation {
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

public extension CDConversation {
    @objc(addMessagesObject:)
    @NSManaged func addToMessages(_ value: CDMessage)

    @objc(removeMessagesObject:)
    @NSManaged func removeFromMessages(_ value: CDMessage)

    @objc(addMessages:)
    @NSManaged func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged func removeFromMessages(_ values: NSSet)
}

// MARK: Generated accessors for mutualGroups

public extension CDConversation {
    @objc(addMutualGroupsObject:)
    @NSManaged func addToMutualGroups(_ value: CDMutualGroup)

    @objc(removeMutualGroupsObject:)
    @NSManaged func removeFromMutualGroups(_ value: CDMutualGroup)

    @objc(addMutualGroups:)
    @NSManaged func addToMutualGroups(_ values: NSSet)

    @objc(removeMutualGroups:)
    @NSManaged func removeFromMutualGroups(_ values: NSSet)
}

// MARK: Generated accessors for participants

public extension CDConversation {
    @objc(addParticipantsObject:)
    @NSManaged func addToParticipants(_ value: CDParticipant)

    @objc(removeParticipantsObject:)
    @NSManaged func removeFromParticipants(_ value: CDParticipant)

    @objc(addParticipants:)
    @NSManaged func addToParticipants(_ values: NSSet)

    @objc(removeParticipants:)
    @NSManaged func removeFromParticipants(_ values: NSSet)
}

// MARK: Generated accessors for pinMessages

public extension CDConversation {
    @objc(addPinMessagesObject:)
    @NSManaged func addToPinMessages(_ value: CDMessage)

    @objc(removePinMessagesObject:)
    @NSManaged func removeFromPinMessages(_ value: CDMessage)

    @objc(addPinMessages:)
    @NSManaged func addToPinMessages(_ values: NSSet)

    @objc(removePinMessages:)
    @NSManaged func removeFromPinMessages(_ values: NSSet)
}

// MARK: Generated accessors for tagParticipants

public extension CDConversation {
    @objc(addTagParticipantsObject:)
    @NSManaged func addToTagParticipants(_ value: CDTagParticipant)

    @objc(removeTagParticipantsObject:)
    @NSManaged func removeFromTagParticipants(_ value: CDTagParticipant)

    @objc(addTagParticipants:)
    @NSManaged func addToTagParticipants(_ values: NSSet)

    @objc(removeTagParticipants:)
    @NSManaged func removeFromTagParticipants(_ values: NSSet)
}

public extension CDConversation {
    func update(_ conversation: Conversation) {
        admin = conversation.admin as? NSNumber
        canEditInfo = conversation.canEditInfo as? NSNumber
        canSpam = conversation.canSpam as NSNumber?
        closedThread = conversation.closedThread as NSNumber?
        descriptions = conversation.description
        group = conversation.group as? NSNumber
        id = conversation.id as? NSNumber
        image = conversation.image
        joinDate = conversation.joinDate as? NSNumber
        lastMessage = conversation.lastMessage
        lastParticipantImage = conversation.lastParticipantImage
        lastParticipantName = conversation.lastParticipantName
        lastSeenMessageId = conversation.lastSeenMessageId as? NSNumber
        lastSeenMessageNanos = conversation.lastSeenMessageNanos as? NSNumber
        lastSeenMessageTime = conversation.lastSeenMessageTime as? NSNumber
        mentioned = conversation.mentioned as? NSNumber
        metadata = conversation.metadata
        mute = conversation.mute as? NSNumber
        participantCount = conversation.participantCount as? NSNumber
        partner = conversation.partner as? NSNumber
        partnerLastDeliveredMessageId = conversation.partnerLastDeliveredMessageId as? NSNumber
        partnerLastDeliveredMessageNanos = conversation.partnerLastDeliveredMessageNanos as? NSNumber
        partnerLastDeliveredMessageTime = conversation.partnerLastDeliveredMessageTime as? NSNumber
        partnerLastSeenMessageId = conversation.partnerLastSeenMessageId as? NSNumber
        partnerLastSeenMessageNanos = conversation.partnerLastSeenMessageNanos as? NSNumber
        partnerLastSeenMessageTime = conversation.partnerLastSeenMessageTime as? NSNumber
        pin = conversation.pin as? NSNumber
        time = conversation.time as? NSNumber
        title = conversation.title
        type = conversation.type?.rawValue as? NSNumber
        unreadCount = conversation.unreadCount as? NSNumber
        uniqueName = conversation.uniqueName
        userGroupHash = conversation.userGroupHash
        isArchive = conversation.isArchive as NSNumber?
    }

    func codable(fillLastMessageVO: Bool = true, fillParticipants: Bool = false, fillPinMessages: Bool = true) -> Conversation {
        Conversation(admin: admin?.boolValue,
                     canEditInfo: canEditInfo?.boolValue,
                     canSpam: canSpam?.boolValue,
                     closedThread: closedThread?.boolValue,
                     description: descriptions,
                     group: group?.boolValue,
                     id: id?.intValue,
                     image: image,
                     joinDate: joinDate?.intValue,
                     lastMessage: lastMessage,
                     lastParticipantImage: lastParticipantImage,
                     lastParticipantName: lastParticipantName,
                     lastSeenMessageId: lastSeenMessageId?.intValue,
                     lastSeenMessageNanos: lastSeenMessageNanos?.uintValue,
                     lastSeenMessageTime: lastSeenMessageTime?.uintValue,
                     mentioned: mentioned?.boolValue,
                     metadata: metadata,
                     mute: mute?.boolValue,
                     participantCount: participantCount?.intValue,
                     partner: partner?.intValue,
                     partnerLastDeliveredMessageId: partnerLastDeliveredMessageId?.intValue,
                     partnerLastDeliveredMessageNanos: partnerLastDeliveredMessageNanos?.uintValue,
                     partnerLastDeliveredMessageTime: partnerLastDeliveredMessageTime?.uintValue,
                     partnerLastSeenMessageId: partnerLastSeenMessageId?.intValue,
                     partnerLastSeenMessageNanos: partnerLastSeenMessageNanos?.uintValue,
                     partnerLastSeenMessageTime: partnerLastSeenMessageTime?.uintValue,
                     pin: pin?.boolValue,
                     time: time?.uintValue,
                     title: title,
                     type: ThreadTypes(rawValue: type?.intValue ?? 0),
                     unreadCount: unreadCount?.intValue,
                     uniqueName: uniqueName,
                     userGroupHash: userGroupHash,
                     inviter: inviter?.codable,
                     lastMessageVO: fillLastMessageVO ? lastMessageVO?.codable(fillConversation: false) : nil,
                     participants: fillParticipants ? participants?.allObjects.map { $0 as? CDParticipant }.compactMap { $0?.codable } : nil,
                     pinMessages: fillPinMessages ? pinMessages?.allObjects.compactMap { $0 as? CDMessage }.map { $0.codable(fillConversation: false) } : nil,
                     isArchive: isArchive?.boolValue)
    }
}
