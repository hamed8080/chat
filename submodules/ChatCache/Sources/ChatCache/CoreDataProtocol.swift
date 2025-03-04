//
// CoreDataProtocol.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation

public protocol IdProtocol: Sendable {}
extension NSNumber: IdProtocol {}
extension String: IdProtocol {}

public protocol CacheLogDelegate: AnyObject {
    func log(message: String, persist: Bool, error: Error?)
}

public protocol CoreDataProtocol {
    associatedtype Entity: EntityProtocol
    init(container: PersistentManagerProtocol, logger: CacheLogDelegate)
    var container: PersistentManagerProtocol { get set }
    @MainActor
    var viewContext: CacheManagedContext { get }
    var bgContext: CacheManagedContext { get }
    var logger: CacheLogDelegate { get }
    func idPredicate(id: Entity.Id) -> NSPredicate
    func save(context: CacheManagedContext)
    func saveViewContext()
    func firstOnMain(with id: Entity.Id, context: CacheManagedContext, completion: @escaping @MainActor @Sendable (Entity?) -> Void)
    func first(with id: Entity.Id, context: CacheManagedContext, completion: @escaping @Sendable (Entity?) -> Void)
    func find(predicate: SendableNSPredicate, completion: @escaping @MainActor @Sendable ([Entity]) -> Void)
    func insert(model: Entity.Model, context: CacheManagedContext)
    func insert(models: [Entity.Model])
    func delete(entity: Entity)
    func update(model: Entity.Model, entity: Entity)
    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate)
    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID])
    func insertObjects(_ makeEntities: @escaping @Sendable (CacheManagedContext) throws -> Void)
    func delete(_ id: Int)
    func batchDelete(_ ids: [Int])
    func batchDelete(predicate: NSPredicate)
    func fetchWithOffset(count: Int, offset: Int, predicate: SendableNSPredicate?, sortDescriptor: [SendableNSSortDescriptor]?, _ completion: @escaping @Sendable ([Entity], Int) -> Void)
    @MainActor
    func all() -> [Entity]
    func findOrCreate(_ id: Entity.Id, _ context: CacheManagedContext) -> Entity
    func truncate()
}

/// Optional Implementations.
public extension CoreDataProtocol {
    func update(model: Entity.Model, entity: Entity) {}
    func update(models: [Entity.Model]) {}
    func delete(entity: Entity) {}
}
