//
//  CDFile+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDFile {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDFile> {
        NSFetchRequest<CDFile>(entityName: "CDFile")
    }

    @NSManaged var hashCode: String?
    @NSManaged var name: String?
    @NSManaged var size: NSNumber?
    @NSManaged var type: String?
}

public extension CDFile {
    func update(_ file: File) {
        hashCode = file.hashCode
        name = file.name
        size = file.size as? NSNumber
        type = file.type
    }

    var codable: File {
        File(hashCode: hashCode, name: name, size: size?.intValue, type: type)
    }
}
