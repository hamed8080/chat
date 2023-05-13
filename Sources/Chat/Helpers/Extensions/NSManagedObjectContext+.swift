//
//  NSManagedObjectContext+.swift
//  Chat
//
//  Created by hamed on 3/1/23.
//

import CoreData
extension NSManagedObjectContext {
    func perform(_ block: @escaping () throws -> Void) {
        perform {
            do {
                try block()
            } catch {
                let internalDelegate = ChatManager.activeInstance as? ChatImplementation
                internalDelegate?.logger.log(message: error.localizedDescription, persist: true, type: .internalLog)
            }
        }
    }
}
