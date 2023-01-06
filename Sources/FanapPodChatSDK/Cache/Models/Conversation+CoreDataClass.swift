//
//  Conversation+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Conversation: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        admin = try container.decodeIfPresent(Bool.self, forKey: .admin) as? NSNumber
        canEditInfo = try container.decodeIfPresent(Bool.self, forKey: .canEditInfo) as? NSNumber
        canSpam = try container.decodeIfPresent(Bool.self, forKey: .canSpam) as? NSNumber
        closedThread = try container.decodeIfPresent(Bool.self, forKey: .closedThread) as? NSNumber
        descriptions = try container.decodeIfPresent(String.self, forKey: .description)
        group = try container.decodeIfPresent(Bool.self, forKey: .group) as? NSNumber
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        image = try container.decodeIfPresent(String.self, forKey: .image)
        joinDate = try container.decodeIfPresent(Int.self, forKey: .joinDate) as? NSNumber
        lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        lastParticipantImage = try container.decodeIfPresent(String.self, forKey: .lastParticipantImage)
        lastParticipantName = try container.decodeIfPresent(String.self, forKey: .lastParticipantName)
        lastSeenMessageId = try container.decodeIfPresent(Int.self, forKey: .lastSeenMessageId) as? NSNumber
        lastSeenMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .lastSeenMessageNanos) as? NSNumber
        lastSeenMessageTime = try container.decodeIfPresent(UInt.self, forKey: .lastSeenMessageTime) as? NSNumber
        mentioned = try container.decodeIfPresent(Bool.self, forKey: .mentioned) as? NSNumber
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        mute = try container.decodeIfPresent(Bool.self, forKey: .mute) as? NSNumber
        participantCount = try container.decodeIfPresent(Int.self, forKey: .participantCount) as? NSNumber
        partner = try container.decodeIfPresent(Int.self, forKey: .partner) as? NSNumber
        partnerLastDeliveredMessageId = try container.decodeIfPresent(Int.self, forKey: .partnerLastSeenMessageId) as? NSNumber
        partnerLastDeliveredMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .partnerLastDeliveredMessageNanos) as? NSNumber
        partnerLastDeliveredMessageTime = try container.decodeIfPresent(UInt.self, forKey: .partnerLastDeliveredMessageTime) as? NSNumber
        partnerLastSeenMessageId = try container.decodeIfPresent(Int.self, forKey: .partnerLastSeenMessageId) as? NSNumber
        partnerLastSeenMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .partnerLastSeenMessageNanos) as? NSNumber
        partnerLastSeenMessageTime = try container.decodeIfPresent(UInt.self, forKey: .partnerLastSeenMessageTime) as? NSNumber
        pin = try container.decodeIfPresent(Bool.self, forKey: .pin) as? NSNumber ?? container.decodeIfPresent(Bool.self, forKey: .pinned) as? NSNumber
        time = try container.decodeIfPresent(UInt.self, forKey: .time) as? NSNumber
        title = try container.decodeIfPresent(String.self, forKey: .title)
        type = try container.decodeIfPresent(ThreadTypes.self, forKey: .type)?.rawValue as? NSNumber
        unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount) as? NSNumber
        uniqueName = try container.decodeIfPresent(String.self, forKey: .uniqueName)
        userGroupHash = try container.decodeIfPresent(String.self, forKey: .userGroupHash)
        inviter = try container.decodeIfPresent(Participant.self, forKey: .inviter)
        let participants = try container.decodeIfPresent([Participant].self, forKey: .participants)
        participants?.forEach { participant in
            addToParticipants(participant)
        }
        lastMessageVO = try container.decodeIfPresent(Message.self, forKey: .lastMessageVO)
        pinMessage = try container.decodeIfPresent(PinMessage.self, forKey: .pinMessageVO)
        isArchive = try container.decodeIfPresent(Bool.self, forKey: .archiveThread) as? NSNumber
    }
}

public extension Conversation {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    var threadType: ThreadTypes { ThreadTypes(rawValue: type as? Int ?? -1) ?? .unknown }

    convenience init(
        context: NSManagedObjectContext,
        admin: Bool? = nil,
        canEditInfo: Bool? = nil,
        canSpam: Bool? = nil,
        closedThread: Bool? = nil,
        descriptions: String? = nil,
        group: Bool? = nil,
        id: Int? = nil,
        image: String? = nil,
        joinDate: Int? = nil,
        lastMessage: String? = nil,
        lastParticipantImage: String? = nil,
        lastParticipantName: String? = nil,
        lastSeenMessageId: Int? = nil,
        lastSeenMessageNanos: Int? = nil,
        lastSeenMessageTime: Int? = nil,
        mentioned: Bool? = nil,
        metadata: String? = nil,
        mute: Bool? = nil,
        participantCount: Int? = nil,
        partner: Int? = nil,
        partnerLastDeliveredMessageId: Int? = nil,
        partnerLastDeliveredMessageNanos: Int? = nil,
        partnerLastDeliveredMessageTime: Int? = nil,
        partnerLastSeenMessageId: Int? = nil,
        partnerLastSeenMessageNanos: Int? = nil,
        partnerLastSeenMessageTime: Int? = nil,
        pin: Bool? = nil,
        time: Int? = nil,
        title: String? = nil,
        type: Int? = nil,
        unreadCount: Int? = nil,
        uniqueName: String? = nil,
        userGroupHash: String? = nil,
        inviter: Participant? = nil,
        participants: [Participant]? = nil,
        lastMessageVO: Message? = nil,
        pinMessage: PinMessage? = nil,
        archiveThread: Bool? = nil
    ) {
        self.init(context: context)
        self.admin = admin as? NSNumber
        self.canEditInfo = canEditInfo as? NSNumber
        self.canSpam = canSpam as? NSNumber
        self.closedThread = closedThread as? NSNumber
        self.descriptions = descriptions
        self.group = group as? NSNumber
        self.id = id as? NSNumber
        self.image = image
        self.joinDate = joinDate as? NSNumber
        self.lastMessage = lastMessage
        self.lastParticipantImage = lastParticipantImage
        self.lastParticipantName = lastParticipantName
        self.lastSeenMessageId = lastSeenMessageId as? NSNumber
        self.lastSeenMessageNanos = lastSeenMessageNanos as? NSNumber
        self.lastSeenMessageTime = lastSeenMessageTime as? NSNumber
        self.mentioned = mentioned as? NSNumber
        self.metadata = metadata
        self.mute = mute as? NSNumber
        self.participantCount = participantCount as? NSNumber
        self.partner = partner as? NSNumber
        self.partnerLastDeliveredMessageId = partnerLastDeliveredMessageId as? NSNumber
        self.partnerLastDeliveredMessageNanos = partnerLastDeliveredMessageNanos as? NSNumber
        self.partnerLastDeliveredMessageTime = partnerLastDeliveredMessageTime as? NSNumber
        self.partnerLastSeenMessageId = partnerLastSeenMessageId as? NSNumber
        self.partnerLastSeenMessageNanos = partnerLastSeenMessageNanos as? NSNumber
        self.partnerLastSeenMessageTime = partnerLastSeenMessageTime as? NSNumber
        self.pin = pin as? NSNumber
        self.time = time as? NSNumber
        self.title = title
        self.type = type as? NSNumber
        self.unreadCount = unreadCount as? NSNumber
        self.uniqueName = uniqueName
        self.userGroupHash = userGroupHash
        self.inviter = inviter
        participants?.forEach { participant in
            addToParticipants(participant)
        }
        self.lastMessageVO = lastMessageVO
        self.pinMessage = pinMessage
        isArchive = archiveThread as? NSNumber
    }

    private enum CodingKeys: String, CodingKey {
        case admin
        case canEditInfo
        case canSpam
        case closedThread
        case description
        case group
        case id
        case image
        case joinDate
        case lastMessage
        case lastParticipantImage
        case lastParticipantName
        case lastSeenMessageId
        case lastSeenMessageNanos
        case lastSeenMessageTime
        case mentioned
        case metadata
        case mute
        case participantCount
        case partner
        case partnerLastDeliveredMessageId
        case partnerLastDeliveredMessageNanos
        case partnerLastDeliveredMessageTime
        case partnerLastSeenMessageId
        case partnerLastSeenMessageNanos
        case partnerLastSeenMessageTime
        case pin
        case pinned
        case time
        case title
        case type
        case unreadCount
        case uniqueName
        case userGroupHash
        case inviter
        case participants
        case lastMessageVO
        case pinMessageVO
        case pinMessage // only in encode
        case archiveThread
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(admin as? Bool, forKey: .admin)
        try container.encodeIfPresent(canEditInfo as? Bool, forKey: .canEditInfo)
        try container.encodeIfPresent(canSpam as? Bool, forKey: .canSpam)
        try container.encodeIfPresent(closedThread as? Bool, forKey: .closedThread)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(group as? Bool, forKey: .group)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(joinDate as? Int, forKey: .joinDate)
        try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
        try container.encodeIfPresent(lastParticipantImage, forKey: .lastParticipantImage)
        try container.encodeIfPresent(lastParticipantName, forKey: .lastParticipantName)
        try container.encodeIfPresent(lastSeenMessageId as? Int, forKey: .lastSeenMessageId)
        try container.encodeIfPresent(lastSeenMessageNanos as? Int, forKey: .lastSeenMessageNanos)
        try container.encodeIfPresent(lastSeenMessageTime as? Int, forKey: .lastSeenMessageTime)
        try container.encodeIfPresent(mentioned as? Bool, forKey: .mentioned)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(mute as? Bool, forKey: .mute)
        try container.encodeIfPresent(participantCount as? Int, forKey: .participantCount)
        try container.encodeIfPresent(partner as? Int, forKey: .partner)
        try container.encodeIfPresent(partnerLastDeliveredMessageId as? Int, forKey: .partnerLastDeliveredMessageId)
        try container.encodeIfPresent(partnerLastDeliveredMessageNanos as? Int, forKey: .partnerLastDeliveredMessageNanos)
        try container.encodeIfPresent(partnerLastDeliveredMessageTime as? Int, forKey: .partnerLastDeliveredMessageTime)
        try container.encodeIfPresent(partnerLastSeenMessageId as? Int, forKey: .partnerLastSeenMessageId)
        try container.encodeIfPresent(partnerLastSeenMessageNanos as? Int, forKey: .partnerLastSeenMessageNanos)
        try container.encodeIfPresent(partnerLastSeenMessageTime as? Int, forKey: .partnerLastSeenMessageTime)
        try container.encodeIfPresent(pin as? Bool, forKey: .pin)
        try container.encodeIfPresent(time as? UInt, forKey: .time)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(type as? Int, forKey: .type)
        try container.encodeIfPresent(unreadCount as? Int, forKey: .unreadCount)
        try container.encodeIfPresent(uniqueName, forKey: .uniqueName)
        try container.encodeIfPresent(userGroupHash, forKey: .userGroupHash)
        try container.encodeIfPresent(inviter, forKey: .inviter)
        try container.encodeIfPresent(lastMessageVO, forKey: .lastMessageVO)
        try container.encodeIfPresent(pinMessage, forKey: .pinMessage)
        try container.encodeIfPresent(isArchive as? Bool, forKey: .archiveThread)
    }
}

public extension Conversation {
//    class func deleteConversations(byTimeStamp timeStamp: Int, logger: Logger?) {
//        let currentTime = Int(Date().timeIntervalSince1970)
//        let predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
//        CMContact.crud.deleteWith(predicate: predicate, logger)
//    }
//
//    class func insertOrUpdate(conversations: [Conversation], resultEntity: ((CMConversation) -> Void)? = nil) {
//        conversations.forEach { conversation in
//            if let findedEntity = CMConversation.crud.find(keyWithFromat: "id == %i", value: conversation.id!) {
//                let cmConversation = convertConversationToCM(conversation: conversation, entity: findedEntity)
//                resultEntity?(cmConversation)
//            } else {
//                CMConversation.crud.insert { entity in
//                    let cmConversation = convertConversationToCM(conversation: conversation, entity: entity)
//                    resultEntity?(cmConversation)
//                }
//            }
//        }
//    }
//
    class func getThreads(req: ThreadsRequest?) -> [Conversation] {
        guard let req = req else { return [] }
        if req.new == true {
            return getNewThreads(count: req.count, offset: req.offset)
        } else {
            return searchThreads(req)
        }
    }
//
//    class func getNewThreads(count: Int, offset: Int) -> [Conversation] {
//        let fetchRequest = crud.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "unreadCount > %i", 0)
//        fetchRequest.fetchLimit = count
//        fetchRequest.fetchOffset = offset
//        let conversations = CMConversation.crud.fetchWith(fetchRequest)
//        return conversations?.map { $0.getCodable() } ?? []
//    }
//
//    class func searchThreads(_ req: ThreadsRequest) -> [Conversation] {
//        let fetchRequest = crud.fetchRequest()
//        fetchRequest.fetchLimit = req.count
//        fetchRequest.fetchOffset = req.offset
//        var orFetchPredicatArray = [NSPredicate]()
//        if let name = req.name, name != "" {
//            let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", name)
//            let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", name)
//            orFetchPredicatArray.append(searchTitle)
//            orFetchPredicatArray.append(searchDescriptions)
//        }
//
//        req.threadIds?.forEach { threadId in
//            orFetchPredicatArray.append(NSPredicate(format: "id == %i", threadId))
//        }
//
//        let archivePredicate = NSPredicate(format: "isArchive == %@", NSNumber(value: req.archived ?? false))
//        orFetchPredicatArray.append(archivePredicate)
//        let orCompound = NSCompoundPredicate(type: .or, subpredicates: orFetchPredicatArray)
//        fetchRequest.predicate = orCompound
//
//        let sortByTime = NSSortDescriptor(key: "time", ascending: false)
//        let sortByPin = NSSortDescriptor(key: "pin", ascending: false)
//        fetchRequest.sortDescriptors = [sortByPin, sortByTime]
//        let threads = crud.fetchWith(fetchRequest)?.compactMap { $0.getCodable() } ?? []
//        return threads
//    }
//
//    class func updateLastSeen(threadId: Int, messageId: Int) {
//        if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
//            let oldMessageSeenId = conversation.lastSeenMessageId as? Int
//            conversation.lastSeenMessageId = NSNumber(value: messageId)
//            if let oldMessageSeenId = oldMessageSeenId,
//               messageId > oldMessageSeenId,
//               let unreadCount = conversation.unreadCount as? Int,
//               unreadCount > 0
//            {
//                conversation.unreadCount = NSNumber(value: unreadCount - 1)
//            }
//        }
//    }
}
