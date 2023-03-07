//
//  CDUserRole+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDUserRole {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDUserRole> {
        NSFetchRequest<CDUserRole>(entityName: "CDUserRole")
    }

    static let entityName = "CDUserRole"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDUserRole {
        CDUserRole(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var image: String?
    @NSManaged var name: String?
    @NSManaged var roles: Data?
    @NSManaged var userId: NSNumber?
    @NSManaged var user: CDUser?
}

public extension CDUserRole {
    func update(_ userRole: UserRole) {
        name = userRole.name
        roles = userRole.roles?.toData()
        userId = userRole.userId as? NSNumber
        image = userRole.image
    }

    var codable: UserRole {
        UserRole(userId: userId?.intValue,
                 name: name,
                 roles: try? JSONDecoder().decode([Roles].self, from: roles ?? Data()),
                 image: image)
    }
}
