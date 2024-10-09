//
// CacheTagParticipantManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheTagParticipantManager: BaseCoreDataManager<CDTagParticipant> {

    public func delete(_ models: [Entity.Model], tagId: Int) {
        let ids = models.compactMap(\.id)
        let predicate = NSPredicate(format: "\(Entity.idName) IN %@ AND %K == %i", ids, #keyPath(CDTagParticipant.tagId), tagId)
        batchDelete(predicate: predicate)
    }
}
