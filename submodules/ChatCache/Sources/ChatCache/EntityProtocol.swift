//
// EntityProtocol.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

public protocol EntityProtocol: NSManagedObject {
    associatedtype Model: Codable
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
    
    static func entityDescription(_ context: NSManagedObjectContextProtocol) -> NSEntityDescription {
        NSEntityDescription.entityDescription(forEntityName: name, in: context)!
    }
    
    static func insertEntity(_ context: NSManagedObjectContextProtocol) -> Self {
        Self(entity: entityDescription(context), insertInto: context as? NSManagedObjectContext)
    }
}

extension NSEntityDescription {
    class func entityDescription(forEntityName entityName: String, in context: NSManagedObjectContextProtocol) -> NSEntityDescription? {
        if let context = context as? NSManagedObjectContext {
            return NSEntityDescription.entity(forEntityName: entityName, in: context)
        } else {
            return NSEntityDescription.entity(forEntityName: entityName, in: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }
}
