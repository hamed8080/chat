//
// CacheTagManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheTagManager: BaseCoreDataManager<CDTag> {
    
    public func getTags(_ completion: @escaping ([Entity]) -> Void) {
        viewContext.perform {
            let req = Entity.fetchRequest()
            req.relationshipKeyPathsForPrefetching = ["tagParticipants"]
            let tags = try self.viewContext.fetch(req)
            completion(tags)
        }
    }
}
