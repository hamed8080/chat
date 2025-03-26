//
//  NSManagedObjectContextProtocol.swift
//  LeitnerBox
//
//  Created by hamed on 2/24/23.
//

import CoreData
import Foundation

public protocol NSManagedObjectContextProtocol: AnyObject {
    func save() throws
    func reset()
    func rollback()
    func refreshAllObjects()
    var insertedObjects: Set<NSManagedObject> { get }
    var updatedObjects: Set<NSManagedObject> { get }
    var deletedObjects: Set<NSManagedObject> { get }
    var registeredObjects: Set<NSManagedObject> { get }
    func insert(_ object: NSManagedObject)
    func delete(_ object: NSManagedObject)
    func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult
    func count<T>(for request: NSFetchRequest<T>) throws -> Int where T: NSFetchRequestResult
    var hasChanges: Bool { get }
    var name: String? { get }
    func perform(_ block: @escaping () throws -> Void, errorCompeletion: ((Error) -> Void)?)
}

extension NSManagedObjectContext: NSManagedObjectContextProtocol {}

public struct CacheManagedContext: @unchecked Sendable {
    public let context: NSManagedObjectContextProtocol
    
    public init(context: NSManagedObjectContextProtocol) {
        self.context = context
    }
    
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        return try context.fetch(request)
    }
    
    func perform(_ block: @escaping () throws -> Void, errorCompeletion: ((Error) -> Void)? = nil) {
        context.perform(block, errorCompeletion: errorCompeletion)
    }
    
    func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        try context.execute(request)
    }
    
    func insert(_ object: NSManagedObject) {
        context.insert(object)
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func count<T>(for request: NSFetchRequest<T>) throws -> Int where T: NSFetchRequestResult {
        try context.count(for: request)
    }
    
    func save() throws {
        try context.save()
    }
    
    func reset() {
        context.reset()
    }
    
    func rollback() {
        context.rollback()
    }
    
    func refreshAllObjects() {
        context.refreshAllObjects()
    }
    
    var hasChanges: Bool {
        context.hasChanges
    }
}

public extension NSManagedObjectContextProtocol {
    var sendable: CacheManagedContext { CacheManagedContext(context: self) }
}

public extension NSManagedObjectContextProtocol {
    func perform(_ block: @escaping () throws -> Void, errorCompeletion: ((Error) -> Void)? = nil) {
        if let context = self as? NSManagedObjectContext {
            context.perform {
                do {
                    try block()
                } catch {
                    errorCompeletion?(error)
                }
            }
        } else {
            do {
                try block()
            } catch {
                errorCompeletion?(error)
            }
        }
    }
}
