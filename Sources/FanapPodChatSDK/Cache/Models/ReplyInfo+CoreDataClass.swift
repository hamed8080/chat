//
//  ReplyInfo+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class ReplyInfo: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted) as? NSNumber
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageType = try container.decodeIfPresent(Int.self, forKey: .messageType) as? NSNumber
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedToMessageId = try container.decodeIfPresent(Int.self, forKey: .repliedToMessageId) as? NSNumber
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        let repliedToMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageNanos)
        let repliedToMessageTime = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageTime)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        if let repliedToMessageTime = repliedToMessageTime, let repliedToMessageNanos = repliedToMessageNanos {
            time = ((UInt(repliedToMessageTime / 1000) * 1_000_000_000) + repliedToMessageNanos) as NSNumber?
        }
    }
}

extension ReplyInfo {
    convenience init(
        context: NSManagedObjectContext,
        deleted: Bool?,
        repliedToMessageId: Int?,
        message: String?,
        messageType: Int?,
        metadata: String?,
        systemMetadata: String?,
        time: UInt?,
        participant: Participant?
    ) {
        self.init(context: context)
        self.deleted = deleted as? NSNumber
        self.repliedToMessageId = repliedToMessageId as? NSNumber
        self.message = message
        self.messageType = messageType as? NSNumber
        self.metadata = metadata
        self.systemMetadata = systemMetadata
        self.time = time as? NSNumber
        self.participant = participant
    }

    private enum CodingKeys: String, CodingKey {
        case deleted
        case message
        case messageType
        case metadata
        case repliedToMessageId
        case systemMetadata
        case repliedToMessageNanos
        case repliedToMessageTime
        case participant
        case time
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deleted as? Bool, forKey: .deleted)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(messageType as? Int, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedToMessageId as? Int, forKey: .repliedToMessageId)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(time as? Int, forKey: .time)
        try container.encodeIfPresent(participant, forKey: .participant)
    }
}

// public extension CMReplyInfo {
//    static let crud = CoreDataCrud<CMReplyInfo>(entityName: "CMReplyInfo")
//
//    func getCodable() -> ReplyInfo {
//        ReplyInfo(deleted: isDeleted,
//                  repliedToMessageId: repliedToMessageId as? Int,
//                  message: message,
//                  messageType: messageType as? Int,
//                  metadata: metadata,
//                  systemMetadata: systemMetadata,
//                  time: time as? UInt,
//                  participant: participant?.getCodable())
//    }
//
//    class func convertReplyInfoToCM(replyInfo: ReplyInfo, messageId: Int?, threadId: Int?, entity: CMReplyInfo? = nil) -> CMReplyInfo {
//        let model = entity ?? CMReplyInfo()
//        model.messageId = messageId as NSNumber?
//        model.deletedd = replyInfo.deleted as NSNumber?
//        model.message = replyInfo.message
//        model.messageType = replyInfo.messageType as NSNumber?
//        model.metadata = replyInfo.metadata
//        model.repliedToMessageId = replyInfo.repliedToMessageId as NSNumber?
//        model.systemMetadata = replyInfo.systemMetadata
//        model.time = replyInfo.time as NSNumber?
//        if let participant = replyInfo.participant {
//            CMParticipant.insertOrUpdate(participant: participant, threadId: threadId) { resultEntity in
//                model.participant = resultEntity
//            }
//        }
//        return model
//    }
//
//    class func insertOrUpdate(replyInfo: ReplyInfo, messageId: Int?, threadId: Int?, resultEntity: ((CMReplyInfo) -> Void)? = nil) {
//        if let messageId = messageId, let findedEntity = CMReplyInfo.crud.find(keyWithFromat: "messageId == %i", value: messageId) {
//            let cmReplyInfo = convertReplyInfoToCM(replyInfo: replyInfo, messageId: messageId, threadId: threadId, entity: findedEntity)
//            resultEntity?(cmReplyInfo)
//        } else {
//            CMReplyInfo.crud.insert { cmLinkedUserEntity in
//                let cmLinkedUser = convertReplyInfoToCM(replyInfo: replyInfo, messageId: messageId, threadId: threadId, entity: cmLinkedUserEntity)
//                resultEntity?(cmLinkedUser)
//            }
//        }
//    }
// }
