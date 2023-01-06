//
//  Image+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Image: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actualWidth = try container.decodeIfPresent(Int.self, forKey: .actualWidth) as? NSNumber
        actualHeight = try container.decodeIfPresent(Int.self, forKey: .actualHeight) as? NSNumber
        height = try container.decodeIfPresent(Int.self, forKey: .height) as? NSNumber
        width = try container.decodeIfPresent(Int.self, forKey: .width) as? NSNumber
        size = try container.decodeIfPresent(Int.self, forKey: .size) as? NSNumber
        name = try container.decodeIfPresent(String.self, forKey: .name)
        hashCode = try container.decodeIfPresent(String.self, forKey: .hashCode)
    }
}

extension Image {
    private enum CodingKeys: String, CodingKey {
        case actualHeight
        case actualWidth
        case hashCode
        case height
        case name
        case size
        case width
    }

    convenience init(
        context: NSManagedObjectContext,
        actualWidth: Int? = nil,
        actualHeight: Int? = nil,
        height: Int? = nil,
        width: Int? = nil,
        size: Int? = nil,
        name: String? = nil,
        hashCode: String? = nil
    ) {
        self.init(context: context)
        self.actualWidth = actualWidth as? NSNumber
        self.actualHeight = actualHeight as? NSNumber
        self.height = height as? NSNumber
        self.width = width as? NSNumber
        self.size = size as? NSNumber
        self.name = name
        self.hashCode = hashCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(actualWidth as? Int, forKey: .actualWidth)
        try container.encodeIfPresent(actualHeight as? Int, forKey: .actualHeight)
        try container.encodeIfPresent(height as? Int, forKey: .height)
        try container.encodeIfPresent(width as? Int, forKey: .width)
        try container.encodeIfPresent(size as? Int, forKey: .size)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(hashCode, forKey: .hashCode)
    }
}

// public extension CMImage {
//    static let crud = CoreDataCrud<CMImage>(entityName: "CMImage")
//
//    func getCodable() -> ImageModel? {
//        guard let hashCode = hashCode else { return nil }
//        return ImageModel(actualHeight: actualHeight as? Int,
//                          actualWidth: actualWidth as? Int,
//                          hashCode: hashCode,
//                          height: height as? Int,
//                          name: name ?? "",
//                          size: size as? Int,
//                          width: width as? Int)
//    }
//
//    class func convertToCM(request: ImageModel, entity: CMImage? = nil) -> CMImage {
//        let model = entity ?? CMImage()
//        model.actualHeight = request.actualHeight as NSNumber?
//        model.actualWidth = request.actualWidth as NSNumber?
//        model.hashCode = request.hashCode
//        model.height = request.height as NSNumber?
//        model.name = request.name
//        model.size = request.size as NSNumber?
//        model.width = request.width as NSNumber?
//
//        return model
//    }
//
//    class func insert(request: ImageModel, resultEntity: ((CMImage) -> Void)? = nil) {
//        CMImage.crud.insert { cmEntity in
//            let cmEntity = convertToCM(request: request, entity: cmEntity)
//            resultEntity?(cmEntity)
//        }
//    }
//
//    class func deleteAndInsert(imageModel: ImageModel, logger: Logger?) {
//        CMImage.crud.deleteWith(predicate: NSPredicate(format: "hashCode == %@", imageModel.hashCode), logger)
//        CMImage.insert(request: imageModel)
//    }
// }
