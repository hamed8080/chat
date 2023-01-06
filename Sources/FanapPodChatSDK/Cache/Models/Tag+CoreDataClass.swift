//
//  Tag+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Tag: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Bool.self, forKey: .id) as? NSNumber
        name = try container.decodeIfPresent(String.self, forKey: .name)
        active = try container.decodeIfPresent(Bool.self, forKey: .active) as? NSNumber
        let tagParticipants = try container.decodeIfPresent([TagParticipant].self, forKey: .tagParticipants)
        tagParticipants?.forEach { tagParticipant in
            addToTagParticipants(tagParticipant)
        }
    }
}

public extension Tag {
    convenience init(
        context: NSManagedObjectContext,
        id: Int,
        name: String,
        active: Bool,
        tagParticipants: [TagParticipant]? = nil
    ) {
        self.init(context: context)
        self.id = id as NSNumber?
        self.name = name
        self.active = active as NSNumber?
        tagParticipants?.forEach { tagParticipant in
            addToTagParticipants(tagParticipant)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case active
        case tagParticipants = "tagParticipantVOList"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(active as? Bool, forKey: .active)
    }
}

// public extension CMTag {
//
//    class func insertOrUpdate(tags: [Tag], resultEntity: ((CMTag) -> Void)? = nil) {
//        tags.forEach { tag in
//            if let findedEntity = CMTag.crud.find(keyWithFromat: "id == %i", value: tag.id) {
//                let cmTag = convertToCM(tag: tag, entity: findedEntity)
//                resultEntity?(cmTag)
//            } else {
//                CMTag.crud.insert { cmTagEntity in
//                    let cmTag = convertToCM(tag: tag, entity: cmTagEntity)
//                    resultEntity?(cmTag)
//                }
//            }
//        }
//    }
//
//    class func addParticipant(tagId: Int, tagParticipant: CMTagParticipant) {
//        if let tag = CMTag.crud.find(keyWithFromat: "id == %i", value: tagId) {
//            tag.tagParticipants?.insert(tagParticipant)
//        }
//    }
// }
