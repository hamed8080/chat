//
//  File+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class File: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hashCode = try container.decodeIfPresent(String.self, forKey: .hashCode)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        size = try container.decodeIfPresent(Int.self, forKey: .size) as? NSNumber
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

extension File {
    private enum CodingKeys: String, CodingKey {
        case hashCode
        case name
        case size
        case type
    }

    convenience init(
        context: NSManagedObjectContext,
        hashCode: String? = nil,
        name: String? = nil,
        size: Int? = nil,
        type: String? = nil
    ) {
        self.init(context: context)
        self.hashCode = hashCode
        self.name = name
        self.size = size as? NSNumber
        self.type = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hashCode, forKey: .hashCode)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(size as? Int, forKey: .size)
        try container.encodeIfPresent(type, forKey: .type)
    }
}

// public extension CMFile {
//    class func insert(request: FileModel, resultEntity: ((CMFile) -> Void)? = nil) {
//        CMFile.crud.insert { cmEntity in
//            let cmEntity = convertToCM(request: request, entity: cmEntity)
//            resultEntity?(cmEntity)
//        }
//    }
//
//    class func deleteAndInsert(fileModel: FileModel, logger: Logger?) {
//        CMFile.crud.deleteWith(predicate: NSPredicate(format: "hashCode == %@", fileModel.hashCode), logger)
//        CMFile.insert(request: fileModel)
//    }
// }
