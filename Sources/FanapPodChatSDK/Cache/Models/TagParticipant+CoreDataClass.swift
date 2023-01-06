//
//  TagParticipant+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class TagParticipant: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        active = try container.decodeIfPresent(Bool.self, forKey: .active) as? NSNumber
        tagId = try container.decodeIfPresent(Int.self, forKey: .tagId) as? NSNumber
        if let threadId = try? container.decodeIfPresent(Int.self, forKey: .threadId) {
            let thread = Conversation(context: context, id: threadId)
            addToConversation(thread)
        }
        id = try container.decodeIfPresent(Bool.self, forKey: .id) as? NSNumber
    }
}

public extension TagParticipant {
    convenience init(
        context: NSManagedObjectContext,
        id: Int? = nil,
        active: Bool? = nil,
        tagId: Int? = nil,
        threadId: Int? = nil,
        conversation: Conversation? = nil
    ) {
        self.init(context: context)
        self.id = id as? NSNumber
        self.active = active as? NSNumber
        self.tagId = tagId as? NSNumber
        self.threadId = threadId as? NSNumber
        if let conversation = conversation {
            addToConversation(conversation)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case active
        case tagId
        case threadId
        case conversation = "conversationVO"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(active as? Bool, forKey: .active)
        try container.encodeIfPresent(tagId as? Bool, forKey: .tagId)
        try container.encodeIfPresent(threadId as? Bool, forKey: .threadId)
    }
}

// public extension CMTagParticipant {
//    class func insertOrUpdate(tagParticipant: TagParticipant, tagId: Int, resultEntity: ((CMTagParticipant) -> Void)? = nil) {
//        if let id = tagParticipant.id, let findedEntity = CMTagParticipant.crud.find(keyWithFromat: "id == %i", value: id) {
//            let cmTagParticipant = convertToCM(tagParticipant: tagParticipant, tagId: tagId, entity: findedEntity)
//            resultEntity?(cmTagParticipant)
//        } else {
//            CMTagParticipant.crud.insert { cmTagParticipantEntity in
//                let cmTagParticipant = convertToCM(tagParticipant: tagParticipant, tagId: tagId, entity: cmTagParticipantEntity)
//                resultEntity?(cmTagParticipant)
//            }
//        }
//    }
// }
