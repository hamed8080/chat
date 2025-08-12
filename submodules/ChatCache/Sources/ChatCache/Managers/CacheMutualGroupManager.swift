//
// CacheMutualGroupManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheMutualGroupManager: BaseCoreDataManager<CDMutualGroup>, @unchecked Sendable {

    public func insert(_ threads: [Conversation], idType: InviteeTypes = .unknown, mutualId: String?) {
        let model = Entity.Model(idType: idType , mutualId: mutualId, conversations: threads)
        insert(models: [model])
    }

    @MainActor
    public func mutualGroups(_ id: String) -> [Entity] {
        let req = Entity.fetchRequest()
        req.predicate = NSPredicate(format: "mutualId == %@", id)
        return (try? self.viewContext.fetch(req)) ?? []
    }
}
