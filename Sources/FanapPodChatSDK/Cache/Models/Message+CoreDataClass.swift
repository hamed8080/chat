//
//  Message+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Message: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deletable = try container.decodeIfPresent(Bool.self, forKey: .deletable) as? NSNumber
        delivered = try container.decodeIfPresent(Bool.self, forKey: .delivered) as? NSNumber
        editable = try container.decodeIfPresent(Bool.self, forKey: .editable) as? NSNumber
        edited = try container.decodeIfPresent(Bool.self, forKey: .edited) as? NSNumber
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        mentioned = try container.decodeIfPresent(Bool.self, forKey: .mentioned) as? NSNumber
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)?.rawValue as? NSNumber
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned) as? NSNumber
        previousId = try container.decodeIfPresent(Int.self, forKey: .previousId) as? NSNumber
        seen = try container.decodeIfPresent(Bool.self, forKey: .seen) as? NSNumber
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        time = try container.decodeIfPresent(UInt.self, forKey: .time) as? NSNumber
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
        conversation = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
        forwardInfo = try container.decodeIfPresent(ForwardInfo.self, forKey: .forwardInfo)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        ownerId = participant?.id
        replyInfo = try container.decodeIfPresent(ReplyInfo.self, forKey: .replyInfoVO)
        // self.threadId       = threadId
    }
}

public extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    convenience init(
        context: NSManagedObjectContext,
        threadId: Int? = nil,
        deletable: Bool? = nil,
        delivered: Bool? = nil,
        editable: Bool? = nil,
        edited: Bool? = nil,
        id: Int? = nil,
        mentioned: Bool? = nil,
        message: String? = nil,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        ownerId: Int? = nil,
        pinned: Bool? = nil,
        previousId: Int? = nil,
        seen: Bool? = nil,
        systemMetadata: String? = nil,
        time: UInt? = nil,
        uniqueId: String? = nil,
        conversation: Conversation? = nil,
        forwardInfo: ForwardInfo? = nil,
        participant: Participant? = nil,
        replyInfo: ReplyInfo? = nil
    ) {
        self.init(context: context)
        self.threadId = threadId as? NSNumber
        self.deletable = deletable as? NSNumber
        self.delivered = delivered as? NSNumber
        self.editable = editable as? NSNumber
        self.edited = edited as? NSNumber
        self.id = id as? NSNumber
        self.mentioned = mentioned as? NSNumber
        self.message = message
        self.messageType = messageType?.rawValue as? NSNumber
        self.metadata = metadata
        self.ownerId = ownerId as? NSNumber ?? participant?.id
        self.pinned = pinned as? NSNumber
        self.previousId = previousId as? NSNumber
        self.seen = seen as? NSNumber
        self.systemMetadata = systemMetadata
        self.time = time as? NSNumber
        self.uniqueId = uniqueId
        self.conversation = conversation
        self.forwardInfo = forwardInfo
        self.participant = participant
        self.replyInfo = replyInfo
    }

    private enum CodingKeys: String, CodingKey {
        case deletable
        case delivered
        case editable
        case edited
        case id
        case mentioned
        case message
        case messageType
        case metadata
        case pinned
        case previousId
        case seen
        case systemMetadata
        case time
        case uniqueId
        case conversation
        case forwardInfo
        case participant
        case replyInfoVO
        case ownerId // only in Encode
        case replyInfo // only in Encode
        case threadId // only in Encode
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deletable as? Bool, forKey: .deletable)
        try container.encodeIfPresent(delivered as? Bool, forKey: .delivered)
        try container.encodeIfPresent(editable as? Bool, forKey: .editable)
        try container.encodeIfPresent(edited as? Bool, forKey: .edited)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(mentioned as? Bool, forKey: .mentioned)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(messageType as? Int, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(ownerId as? Bool, forKey: .ownerId)
        try container.encodeIfPresent(previousId as? Bool, forKey: .previousId)
        try container.encodeIfPresent(seen as? Bool, forKey: .seen)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(threadId as? Bool, forKey: .threadId)
        try container.encodeIfPresent(time as? Bool, forKey: .time)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(conversation, forKey: .conversation)
        try container.encodeIfPresent(forwardInfo, forKey: .forwardInfo)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(replyInfo, forKey: .replyInfo)
    }

    // FIXME: need fix with object decoding in this calss with FileMetaData for proerty metadata
    var metaData: FileMetaData? {
        guard let metadata = metadata?.data(using: .utf8),
              let metaData = try? JSONDecoder().decode(FileMetaData.self, from: metadata) else { return nil }
        return metaData
    }
}

//
// public extension CMMessage {

//
//    class func insertOrUpdate(message: Message, conversation: CMConversation? = nil, resultEntity: ((CMMessage) -> Void)? = nil) {
//        if let id = message.id, let findedEntity = CMMessage.crud.find(keyWithFromat: "id == %i", value: id) {
//            let cmMessage = convertMesageToCM(message: message, entity: findedEntity, conversation: conversation)
//            resultEntity?(cmMessage)
//        } else if let conversation = message.conversation {
//            CMConversation.insertOrUpdate(conversations: [conversation]) { conversationEntity in
//                CMMessage.crud.insert { cmMessage in
//                    let cmMessage = convertMesageToCM(message: message, entity: cmMessage, conversation: conversationEntity)
//                    resultEntity?(cmMessage)
//                }
//            }
//        }
//    }
//
//    class func fetchRequestWithGetHistoryRequest(req: GetHistoryRequest) -> NSFetchRequest<NSFetchRequestResult> {
//        let fetchRequest = crud.fetchRequest()
//        fetchRequest.fetchOffset = req.offset
//        fetchRequest.fetchLimit = req.count
//        let sortByTime = NSSortDescriptor(key: "time", ascending: (req.order == Ordering.asc.rawValue) ? true : false)
//        fetchRequest.sortDescriptors = [sortByTime]
//        if let messageId = req.messageId {
//            fetchRequest.predicate = NSPredicate(format: "id == %i", messageId)
//        } else if let uniqueIds = req.uniqueIds {
//            fetchRequest.predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
//        } else {
//            var predicateArray = [NSPredicate]()
//            predicateArray.append(NSPredicate(format: "conversation.id == %i", req.threadId))
//            if let formTime = req.fromTime as? NSNumber {
//                predicateArray.append(NSPredicate(format: "time >= %@", formTime))
//            }
//            if let toTime = req.toTime as? NSNumber {
//                predicateArray.append(NSPredicate(format: "time <= %@", toTime))
//            }
//            if let query = req.query, query != "" {
//                predicateArray.append(NSPredicate(format: "message CONTAINS[cd] %@", query))
//            }
//            if let messageType = req.messageType {
//                predicateArray.append(NSPredicate(format: "messageType == %i", messageType))
//            }
//            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
//            fetchRequest.predicate = compoundPredicate
//        }
//        return fetchRequest
//    }
//
//    /// When a message is sent successfully the id of the message will be filled in the type 2 response
//    /// so we know that the message is added on the server side properly.
//    class func messageSentToUserToUser(_: MessageResponse) {}
//
//    class func deliveredToUser(_ deliverResponse: MessageResponse) {
//        if let messageId = deliverResponse.messageId, let threadId = deliverResponse.threadId {
//            let messageEntity = CMMessage.crud.fetchWith(NSPredicate(format: "(conversation.id == %i OR threadId == %i) AND id == %i", threadId, threadId, messageId))?.first
//            messageEntity?.delivered = NSNumber(booleanLiteral: true)
//        }
//    }
//
//    class func updateSeenByUser(_ seenResponse: MessageResponse) {
//        if let messageId = seenResponse.messageId, let threadId = seenResponse.threadId {
//            CMMessage.crud.fetchWith(NSPredicate(format: "(conversation.id == %i OR threadId == %i) AND id <= %i AND seen == NULL", threadId, threadId, messageId))?.forEach { messageEntity in
//                messageEntity.delivered = NSNumber(booleanLiteral: true)
//                messageEntity.seen = NSNumber(booleanLiteral: true)
//            }
//        }
//    }
// }
