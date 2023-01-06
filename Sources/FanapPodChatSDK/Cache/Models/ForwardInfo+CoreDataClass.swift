//
//  ForwardInfo+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class ForwardInfo: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participant)
        conversation = try container?.decodeIfPresent(Conversation.self, forKey: .conversation)
    }

    private enum CodingKeys: String, CodingKey {
        case conversation
        case participant
    }

    public convenience init(context: NSManagedObjectContext, conversation: Conversation?, participant: Participant?) {
        self.init(context: context)
        self.conversation = conversation
        self.participant = participant
    }
}

public extension ForwardInfo {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(conversation, forKey: .conversation)
    }
}

//
// public extension CMForwardInfo {
//    static let crud = CoreDataCrud<CMForwardInfo>(entityName: "CMForwardInfo")
//
//    func getCodable() -> ForwardInfo {
//        ForwardInfo(conversation: conversation?.getCodable(),
//                    participant: participant?.getCodable())
//    }
//
//    class func convertForwardInfoToCM(forwardInfo: ForwardInfo, messageId: Int?, threadId: Int?, entity: CMForwardInfo? = nil) -> CMForwardInfo {
//        let model = entity ?? CMForwardInfo()
//        model.messageId = messageId as NSNumber?
//        if let participant = forwardInfo.participant {
//            CMParticipant.insertOrUpdate(participant: participant, threadId: threadId) { resultEntity in
//                model.participant = resultEntity
//            }
//        }
//
//        if let conversation = forwardInfo.conversation {
//            if let threadId = conversation.id, let threadEnitity = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
//                model.conversation = threadEnitity
//            } else {
//                CMConversation.insertOrUpdate(conversations: [conversation]) { resultEntity in
//                    model.conversation = resultEntity
//                }
//            }
//        }
//        return model
//    }
//
//    class func insertOrUpdate(forwardInfo: ForwardInfo, messageId: Int?, threadId: Int?, resultEntity: ((CMForwardInfo) -> Void)? = nil) {
//        if let messageId = messageId, let findedEntity = CMForwardInfo.crud.find(keyWithFromat: "messageId == %i", value: messageId) {
//            let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo, messageId: messageId, threadId: threadId, entity: findedEntity)
//            resultEntity?(cmForwardInfo)
//        } else {
//            CMForwardInfo.crud.insert { cmForwardInfoEntity in
//                let cmForwardInfo = convertForwardInfoToCM(forwardInfo: forwardInfo, messageId: messageId, threadId: threadId, entity: cmForwardInfoEntity)
//                resultEntity?(cmForwardInfo)
//            }
//        }
//    }
// }
