//
//  CurrentUserRoles+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class CurrentUserRoles: NSManagedObject {}

public class CMCurrentUserRoles: NSManagedObject {
    func updateObject(with roles: [Roles], onThreadId threadId: Int) {
        self.threadId = threadId as NSNumber?
        self.roles = RolesArray(roles: roles)
    }
}

public class RolesArray: NSObject, NSCoding {
    public var roles: [String] = []

    enum Key: String {
        case roles
    }

    init(roles: [String]) {
        self.roles = roles
    }

    init(roles: [Roles]) {
        var myRoles: [String] = []
        for role in roles {
            myRoles.append(role.rawValue)
        }
        self.roles = myRoles
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(roles, forKey: Key.roles.rawValue)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        let myRoles = aDecoder.decodeObject(forKey: Key.roles.rawValue) as? [String]
        self.init(roles: myRoles ?? [])
    }
}

// public extension CMCurrentUserRoles {
//
//    class func insertOrUpdate(roles: [Roles], threadId: Int, resultEntity: ((CMCurrentUserRoles) -> Void)? = nil) {
//        if let findedEntity = CMCurrentUserRoles.crud.find(keyWithFromat: "threadId == %i", value: threadId) {
//            let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: findedEntity)
//            resultEntity?(cmUserRoles)
//        } else {
//            CMCurrentUserRoles.crud.insert { cmRolesEntity in
//                let cmUserRoles = convertRoleToCM(roles: roles, threadId: threadId, entity: cmRolesEntity)
//                resultEntity?(cmUserRoles)
//            }
//        }
//    }
// }
