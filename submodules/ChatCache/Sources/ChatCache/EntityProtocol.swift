//
// EntityProtocol.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

public protocol EntityProtocol: NSManagedObject {
    associatedtype Model: Codable & Sendable
    associatedtype Id: IdProtocol
    static var name: String { get }
    static var queryIdSpecifier: String { get }
    static var idName: String { get }
    func update(_ model: Model)
}

public extension EntityProtocol {
    static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: name)
    }
    
    static func entityDescription(_ context: CacheManagedContext) -> NSEntityDescription {
        NSEntityDescription.entityDescription(forEntityName: name, in: context)!
    }
    
    static func insertEntity(_ context: CacheManagedContext) -> Self {
        Self(entity: entityDescription(context), insertInto: context.context as? NSManagedObjectContext)
    }
}

extension NSEntityDescription {
    class func entityDescription(forEntityName entityName: String, in context: CacheManagedContext) -> NSEntityDescription? {
        if let context = context.context as? NSManagedObjectContext {
            return NSEntityDescription.entity(forEntityName: entityName, in: context)
        } else {
            return NSEntityDescription.entity(forEntityName: entityName, in: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }
}
