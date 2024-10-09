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
