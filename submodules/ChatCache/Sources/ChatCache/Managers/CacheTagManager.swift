//
// CacheTagManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheTagManager: BaseCoreDataManager<CDTag>, @unchecked Sendable {
    
    @MainActor
    public func getTags() -> [Entity] {
        let req = Entity.fetchRequest()
        req.relationshipKeyPathsForPrefetching = ["tagParticipants"]
        return (try? self.viewContext.fetch(req)) ?? []
    }
}
