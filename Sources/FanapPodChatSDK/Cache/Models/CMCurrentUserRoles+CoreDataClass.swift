//
// CMCurrentUserRoles+CoreDataClass.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import CoreData
import Foundation

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
