//
// CacheCoreDataFileManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheCoreDataFileManager: BaseCoreDataManager<CDFile>, @unchecked Sendable {
    public func first(hashCode: String, completion: @escaping @Sendable (Entity.Model?) -> Void) {
        firstOnMain(with: hashCode, context: viewContext) { file in
            let file = file?.codable
            completion(file)
        }
    }
    
    public func first(hashCode: String) async -> Entity.Model? {
        typealias EntityResult = CheckedContinuation<Entity.Model?, Never>
        return await withCheckedContinuation { (continuation: EntityResult) in
            first(hashCode: hashCode) { model in
                continuation.resume(with: .success(model))
            }
        }
    }
}
