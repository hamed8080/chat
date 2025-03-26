//
// CDCurrentUserRole+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDCurrentUserRole {
    typealias Entity = CDCurrentUserRole
    typealias Model = UserRole
    typealias Id = NSNumber
    static let name = "CDCurrentUserRole"
    static let queryIdSpecifier: String = "%@"
    static let idName = "threadId"
}

public extension CDCurrentUserRole {
    @NSManaged var roles: Data?
    @NSManaged var threadId: NSNumber?
}

public extension CDCurrentUserRole {
    func update(_ model: Model) {
        roles = model.roles?.data ?? roles
        threadId = model.threadId as? NSNumber ?? threadId
    }

    var codable: Model {
        var decodecRoles: [Roles]?
        if let data = self.roles {
           decodecRoles = try? JSONDecoder.instance.decode([Roles].self, from: data)
        }
        return UserRole(threadId: threadId?.intValue, roles: decodecRoles)
    }
}
