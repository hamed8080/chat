//
// CDLog+CoreDataProperties.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation

@objc(CDLog)
public final class CDLog: NSManagedObject {}

public extension CDLog {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDLog> {
        NSFetchRequest<CDLog>(entityName: "CDLog")
    }

    static let entityName = "CDLog"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDLog {
        CDLog(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var prefix: String?
    @NSManaged var userInfo: Data?
    @NSManaged var id: String?
    @NSManaged var level: NSNumber?
    @NSManaged var message: String?
    @NSManaged var time: NSNumber?
    @NSManaged var type: NSNumber?
}

public extension CDLog {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    func update(_ log: Log) {
        prefix = log.prefix
        id = log.id.uuidString
        level = log.level?.rawValue as? NSNumber
        message = log.message
        time = log.time?.timeIntervalSince1970 as? NSNumber
        type = log.type?.rawValue as? NSNumber
        userInfo = try? CDLog.encoder.encode(log.userInfo)
    }

    var codable: Log {
        Log(prefix: prefix,
            time: Date(timeIntervalSince1970: (time ?? 0).doubleValue),
            message: message,
            level: LogLevel(rawValue: level?.intValue ?? 0),
            id: UUID(uuidString: id ?? "") ?? UUID(),
            type: type == nil ? nil : LogEmitter(rawValue: type!.intValue),
            userInfo: try? CDLog.decoder.decode([String: String].self, from: userInfo ?? Data()))
    }

    class func firstLog(_ logger: Logger, _ context: NSManagedObjectContext, _ completion: @escaping (CDLog?) -> Void) {
        context.perform(logger) {
            let sortByTime = NSSortDescriptor(key: "time", ascending: true)
            let req = CDLog.fetchRequest()
            req.fetchLimit = 1
            req.sortDescriptors = [sortByTime]
            completion(try context.fetch(req).first)
        }
    }

    class func delete(logger: Logger, context: NSManagedObjectContext, logs: [CDLog]) {
        logs.forEach { log in
            context.perform {
                context.delete(log)
                context.save(logger)
            }
        }
    }

    class func insert(_ logger: Logger, _ context: NSManagedObjectContext, _ logs: [Log]) {
        logs.forEach { log in
            let cdLog = CDLog.insertEntity(context)
            cdLog.update(log)
            context.save(logger)
        }
    }

    internal class func clear(prefix: String?, completion: (() -> Void)? = nil) {
        let persistentManager = PersistentManager()
        let context = persistentManager.newBgTask
        context?.perform {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            req.predicate = NSPredicate(format: "prefix == %@", prefix ?? "")
            let batchREQ = NSBatchDeleteRequest(fetchRequest: req)
            batchREQ.resultType = .resultTypeObjectIDs
            _ = try? context?.execute(batchREQ)
            try? context?.save()
            completion?()
        }
    }
}
