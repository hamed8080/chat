//
// CDConversation+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDConversation {
    typealias Entity = CDConversation
    typealias Model = Conversation
    typealias Id = NSNumber
    static let name = "CDConversation"
    static let queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDConversation {
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
    @NSManaged var pinMessage: PinMessageClass?
    @NSManaged var tagParticipants: NSSet?
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
    func update(_ model: Model) {
        if model.id == nil { return }
        admin = model.admin as? NSNumber ?? admin
        canEditInfo = model.canEditInfo as? NSNumber ?? canEditInfo
        canSpam = model.canSpam as NSNumber? ?? canSpam
        closedThread = model.closed as NSNumber? ?? closedThread
        descriptions = model.description ?? descriptions
        group = model.group as? NSNumber ?? group
        id = model.id as? NSNumber ?? id
        image = model.image ?? image
        joinDate = model.joinDate as? NSNumber ?? joinDate
        lastMessage = model.lastMessage ?? lastMessage
        lastParticipantImage = model.lastParticipantImage ?? lastParticipantImage
        lastParticipantName = model.lastParticipantName ?? lastParticipantName
        lastSeenMessageId = model.lastSeenMessageId as? NSNumber ?? lastSeenMessageId
        lastSeenMessageNanos = model.lastSeenMessageNanos as? NSNumber ?? lastSeenMessageNanos
        lastSeenMessageTime = model.lastSeenMessageTime as? NSNumber ?? lastSeenMessageTime
        mentioned = model.mentioned as? NSNumber ?? mentioned
        metadata = model.metadata ?? metadata
        mute = model.mute as? NSNumber ?? mute
        participantCount = model.participantCount as? NSNumber ?? participantCount
        partner = model.partner as? NSNumber ?? partner
        partnerLastDeliveredMessageId = model.partnerLastDeliveredMessageId as? NSNumber ?? partnerLastDeliveredMessageId
        partnerLastDeliveredMessageNanos = model.partnerLastDeliveredMessageNanos as? NSNumber ?? partnerLastDeliveredMessageNanos
        partnerLastDeliveredMessageTime = model.partnerLastDeliveredMessageTime as? NSNumber ?? partnerLastDeliveredMessageTime
        partnerLastSeenMessageId = model.partnerLastSeenMessageId as? NSNumber ?? partnerLastSeenMessageId
        partnerLastSeenMessageNanos = model.partnerLastSeenMessageNanos as? NSNumber ?? partnerLastSeenMessageNanos
        partnerLastSeenMessageTime = model.partnerLastSeenMessageTime as? NSNumber ?? partnerLastSeenMessageTime
        pin = model.pin as? NSNumber ?? pin
        time = model.time as? NSNumber ?? time
        title = model.title ?? title
        type = model.type?.rawValue as? NSNumber ?? type
        unreadCount = model.unreadCount as? NSNumber ?? unreadCount
        uniqueName = model.uniqueName ?? uniqueName
        userGroupHash = model.userGroupHash ?? userGroupHash
        isArchive = model.isArchive as NSNumber? ?? isArchive
        pinMessage = model.pinMessage?.toClass ?? pinMessage
    }

    class func findOrCreate(threadId: Int, context: CacheManagedContext) -> CDConversation {
        let req = CDConversation.fetchRequest()
        req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDConversation.id), threadId.nsValue)
        let entity = (try? context.fetch(req).first) ?? CDConversation.insertEntity(context)
        return entity
    }

    func codable(fillLastMessageVO: Bool = true, fillParticipants: Bool = false) -> Model {
        Conversation(admin: admin?.boolValue,
                     canEditInfo: canEditInfo?.boolValue,
                     canSpam: canSpam?.boolValue,
                     closed: closedThread?.boolValue,
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
                     lastMessageVO: fillLastMessageVO ? lastMessageVO?.codable(fillConversation: false).toLastMessageVO : nil,
                     participants: fillParticipants ? participants?.allObjects.compactMap { ($0 as? CDParticipant)?.codable } : nil,
                     pinMessage: pinMessage?.toStruct,
                     isArchive: isArchive?.boolValue)
    }
}
