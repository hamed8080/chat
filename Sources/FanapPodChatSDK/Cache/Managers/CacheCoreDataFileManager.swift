//
//  CacheCoreDataFileManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheCoreDataFileManager: CoreDataProtocol {
    let idName = "hashCode"
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDFile.entity().name ?? "CDFile"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: File) {
        let entity = CDFile(context: context)
        entity.update(model)
    }

    func insert(models: [File]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: String) -> NSPredicate {
        NSPredicate(format: "\(idName) == %@", id)
    }

    func first(with id: String, _ completion: @escaping (CDFile?) -> Void) {
        context.perform {
            let req = CDFile.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let file = try? self.context.fetch(req).first
            completion(file)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDFile]) -> Void) {
        context.perform {
            let req = CDFile.fetchRequest()
            req.predicate = predicate
            let files = (try? self.context.fetch(req)) ?? []
            completion(files)
        }
    }

    func update(model _: File, entity _: CDFile) {}

    func update(models _: [File]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { [weak self] bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: self?.entityName ?? "")
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDFile) {}
}
