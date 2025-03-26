//
// NSManagedObjectContext+.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
extension NSManagedObjectContext {
    func perform(_ logger: Logger, _ block: @escaping () throws -> Void) {
        perform {
            do {
                try block()
            } catch {
                logger.log(message: error.localizedDescription, persist: true, type: .internalLog)
            }
        }
    }

    func save(_ logger: Logger) {
        if hasChanges == true {
            do {
                try save()
                reset()
                logger.log(message: "Saved successfully in Logger.", persist: false, type: .internalLog)
            } catch {
                let nserror = error as NSError
                logger.createLog(message: "An error has occurred in saving Logger.: \(nserror), \(nserror.userInfo)", persist: true, level: .error, type: .internalLog)
            }
        } else {
            logger.log(message: "No changes has found in the context!", persist: false, type: .internalLog)
        }
    }
}
