//
//  CDImage+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatModels

public extension CDImage {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDImage> {
        NSFetchRequest<CDImage>(entityName: "CDImage")
    }

    static let entityName = "CDImage"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDImage {
        CDImage(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var actualHeight: NSNumber?
    @NSManaged var actualWidth: NSNumber?
    @NSManaged var hashCode: String?
    @NSManaged var height: NSNumber?
    @NSManaged var name: String?
    @NSManaged var size: NSNumber?
    @NSManaged var width: NSNumber?
}

extension CDImage {
    func update(_ image: Image) {
        actualWidth = image.actualWidth as? NSNumber
        actualHeight = image.actualHeight as? NSNumber
        height = image.height as? NSNumber
        width = image.width as? NSNumber
        size = image.size as? NSNumber
        name = image.name
        hashCode = image.hashCode
    }

    public var codable: Image {
        Image(actualWidth: actualWidth?.intValue,
              actualHeight: actualHeight?.intValue,
              height: height?.intValue,
              width: width?.intValue,
              size: size?.intValue,
              name: name,
              hashCode: hashCode)
    }
}
