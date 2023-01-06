//
//  UserRole+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class UserRole: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        roles = try container.decode([Roles].self, forKey: .roles)
        userId = try container.decode(Int.self, forKey: .id) as NSNumber?
        image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}

extension UserRole {
    convenience init(
        context: NSManagedObjectContext,
        userId: Int,
        name: String,
        roles: [Roles]?
    ) {
        self.init(context: context)
        self.userId = userId as NSNumber?
        self.name = name
        self.roles = roles
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case roles
        case image // for decode
        case id // for encode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
        try? container.encodeIfPresent(userId as? Int, forKey: .id)
        try? container.encodeIfPresent(roles, forKey: .roles)
    }
}

//
// public extension CMUserRole {
//
//    class func insertOrUpdate(userRole: UserRole, resultEntity: ((CMUserRole) -> Void)? = nil) {
//        if let findedEntity = CMUserRole.crud.find(keyWithFromat: "id == %i", value: userRole.userId) {
//            let cmUserRole = convertToCM(userRole: userRole, entity: findedEntity)
//            resultEntity?(cmUserRole)
//        } else {
//            CMUserRole.crud.insert { cmUserRoleEntity in
//                let cmUserRole = convertToCM(userRole: userRole, entity: cmUserRoleEntity)
//                resultEntity?(cmUserRole)
//            }
//        }
//    }
// }
