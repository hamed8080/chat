//
// CacheUserManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheUserManager: BaseCoreDataManager<CDUser>, @unchecked Sendable {
 
    public func insert(_ model: Entity.Model, isMe: Bool = false) {
        insertObjects() { context in
            let userEntity = Entity.insertEntity(context)
            userEntity.update(model)
            userEntity.isMe = isMe as NSNumber
        }
    }

    @MainActor
    public func insertOnMain(_ model: Entity.Model, isMe: Bool = false) {
        insertObjects() { context in
            let userEntity = Entity.insertEntity(context)
            userEntity.update(model)
            userEntity.isMe = isMe as NSNumber
        }
    }
    
    @MainActor
    public func fetchCurrentUser() -> Entity? {
        let req = Entity.fetchRequest()
        req.predicate = NSPredicate(format: "isMe == %@", NSNumber(booleanLiteral: true))
        return try? self.viewContext.fetch(req).first
    }
}
