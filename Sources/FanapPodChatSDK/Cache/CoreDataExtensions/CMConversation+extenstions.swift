//
// CMConversation+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension CMConversation {
    static let crud = CoreDataCrud<CMConversation>(entityName: "CMConversation")

    func getCodable() -> Conversation {
        Conversation(admin: admin as? Bool,
                     canEditInfo: canEditInfo as? Bool,
                     canSpam: canSpam as? Bool,
                     closedThread: closedThread as? Bool,
                     description: description,
                     group: group as? Bool,
                     id: id as? Int,
                     image: image,
                     joinDate: joinDate as? Int,
                     lastMessage: lastMessage,
                     lastParticipantImage: lastParticipantImage,
                     lastParticipantName: lastParticipantName,
                     lastSeenMessageId: lastSeenMessageId as? Int,
                     lastSeenMessageNanos: lastSeenMessageNanos as? UInt,
                     lastSeenMessageTime: lastSeenMessageTime as? UInt,
                     mentioned: mentioned as? Bool,
                     metadata: metadata, mute: mute as? Bool,
                     participantCount: participantCount as? Int,
                     partner: partner as? Int,
                     partnerLastDeliveredMessageId: partnerLastDeliveredMessageId as? Int,
                     partnerLastDeliveredMessageNanos: partnerLastDeliveredMessageNanos as? UInt,
                     partnerLastDeliveredMessageTime: partnerLastDeliveredMessageTime as? UInt,
                     partnerLastSeenMessageId: partnerLastSeenMessageId as? Int,
                     partnerLastSeenMessageNanos: partnerLastSeenMessageNanos as? UInt,
                     partnerLastSeenMessageTime: partnerLastSeenMessageTime as? UInt,
                     pin: pin as? Bool,
                     time: time as? UInt,
                     title: title,
                     type: ThreadTypes(rawValue: type as? Int ?? -1),
                     unreadCount: unreadCount as? Int,
                     uniqueName: nil,
                     userGroupHash: userGroupHash,
                     inviter: inviter?.getCodable(),
                     lastMessageVO: lastMessageVO?.getCodable(),
                     participants: participants?.compactMap { $0 as? CMParticipant }.map { $0.getCodable() },
                     pinMessage: pinMessage?.getCodable(),
                     isArchive: isArchive as? Bool)
    }

    internal class func convertConversationToCM(conversation: Conversation, entity: CMConversation? = nil) -> CMConversation {
        let model = entity ?? CMConversation()
        model.admin = conversation.admin as NSNumber?
        model.isArchive = conversation.isArchive as NSNumber?
        model.canEditInfo = conversation.canEditInfo as NSNumber?
        model.canSpam = conversation.canSpam as NSNumber
        model.closedThread = conversation.closedThread as NSNumber
        model.descriptions = conversation.description
        model.group = conversation.group as NSNumber?
        model.id = conversation.id as NSNumber?
        model.image = conversation.image
        model.joinDate = conversation.joinDate as NSNumber?
        model.lastMessage = conversation.lastMessage
        model.lastParticipantImage = conversation.lastParticipantImage
        model.lastParticipantName = conversation.lastParticipantName
        model.lastSeenMessageId = conversation.lastSeenMessageId as NSNumber?
        model.lastSeenMessageNanos = conversation.lastSeenMessageNanos as NSNumber?
        model.lastSeenMessageTime = conversation.lastSeenMessageTime as NSNumber?
        model.mentioned = conversation.mentioned as NSNumber?
        model.metadata = conversation.metadata
        model.mute = conversation.mute as NSNumber?
        model.participantCount = conversation.participantCount as NSNumber?
        model.partner = conversation.partner as NSNumber?
        model.partnerLastDeliveredMessageId = conversation.partnerLastDeliveredMessageId as NSNumber?
        model.partnerLastDeliveredMessageNanos = conversation.partnerLastDeliveredMessageNanos as NSNumber?
        model.partnerLastDeliveredMessageTime = conversation.partnerLastDeliveredMessageTime as NSNumber?
        model.partnerLastSeenMessageId = conversation.partnerLastSeenMessageId as NSNumber?
        model.partnerLastSeenMessageNanos = conversation.partnerLastSeenMessageNanos as NSNumber?
        model.partnerLastSeenMessageTime = conversation.partnerLastSeenMessageTime as NSNumber?
        model.pin = conversation.pin as NSNumber?
        model.time = conversation.time as NSNumber?
        model.title = conversation.title
        model.type = conversation.type?.rawValue as NSNumber?
        model.unreadCount = conversation.unreadCount as NSNumber?
        model.userGroupHash = conversation.userGroupHash
        if let inviter = conversation.inviter {
            CMParticipant.insertOrUpdate(participant: inviter, threadId: conversation.id) { entity in
                model.inviter = entity
            }
        }
        var participants: [CMParticipant] = []
        conversation.participants?.forEach { participant in
            CMParticipant.insertOrUpdate(participant: participant, threadId: conversation.id) { entity in
                participants.append(entity)
            }
        }

        if let pinMessage = conversation.pinMessage {
            CMPinMessage.insertOrUpdate(pinMessage: pinMessage) { entity in
                model.pinMessage = entity
            }
        }

        // only when create newThread the participants propery has value in getThreads we never get that.
        // so just insert participants to CoreData Table and not related to thread.
        if let lastMessage = conversation.lastMessageVO {
            CMMessage.insertOrUpdate(message: lastMessage, conversation: model)
        }

        return model
    }

    class func deleteConversations(byTimeStamp timeStamp: Int) {
        let currentTime = Int(Date().timeIntervalSince1970)
        let predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        CMContact.crud.deleteWith(predicate: predicate)
    }

    class func insertOrUpdate(conversations: [Conversation], resultEntity: ((CMConversation) -> Void)? = nil) {
        conversations.forEach { conversation in
            if let findedEntity = CMConversation.crud.find(keyWithFromat: "id == %i", value: conversation.id!) {
                let cmConversation = convertConversationToCM(conversation: conversation, entity: findedEntity)
                resultEntity?(cmConversation)
            } else {
                CMConversation.crud.insert { entity in
                    let cmConversation = convertConversationToCM(conversation: conversation, entity: entity)
                    resultEntity?(cmConversation)
                }
            }
        }
    }

    class func getThreads(req: ThreadsRequest?) -> [Conversation] {
        guard let req = req else { return [] }
        if req.new == true {
            return getNewThreads(count: req.count, offset: req.offset)
        } else {
            return searchThreads(req)
        }
    }

    class func getNewThreads(count: Int, offset: Int) -> [Conversation] {
        let fetchRequest = crud.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unreadCount > %i", 0)
        fetchRequest.fetchLimit = count
        fetchRequest.fetchOffset = offset
        let conversations = CMConversation.crud.fetchWith(fetchRequest)
        return conversations?.map { $0.getCodable() } ?? []
    }

    class func searchThreads(_ req: ThreadsRequest) -> [Conversation] {
        let fetchRequest = crud.fetchRequest()
        fetchRequest.fetchLimit = req.count
        fetchRequest.fetchOffset = req.offset
        var orFetchPredicatArray = [NSPredicate]()
        if let name = req.name, name != "" {
            let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", name)
            let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", name)
            orFetchPredicatArray.append(searchTitle)
            orFetchPredicatArray.append(searchDescriptions)
        }

        req.threadIds?.forEach { threadId in
            orFetchPredicatArray.append(NSPredicate(format: "id == %i", threadId))
        }

        let archivePredicate = NSPredicate(format: "isArchive == %@", NSNumber(value: req.archived ?? false))
        orFetchPredicatArray.append(archivePredicate)
        let orCompound = NSCompoundPredicate(type: .or, subpredicates: orFetchPredicatArray)
        fetchRequest.predicate = orCompound

        let sortByTime = NSSortDescriptor(key: "time", ascending: false)
        fetchRequest.sortDescriptors = [sortByTime]
        let threads = crud.fetchWith(fetchRequest)?.compactMap { $0.getCodable() } ?? []
        return threads
    }
}
